require 'cfoundry'
require 'config'
require 'class_with_feedback'

# Data layer containing methods to handle cc API App object
class Applications < Uhuru::Webui::ClassWithFeedback

  # Initializes client with target and credentials
  # token = user login token, which contains access right
  # target = cc API target
  #
  def initialize(token, target)
    super()
    @client = CFoundry::V2::Client.new(target, token)
  end

  # Gets app status and number of running instances
  #
  def get_app_running_status(app_guid)
    app = @client.app(app_guid)

    # This call can fail because it eventually has to reach DEAs - it can timeout, staging may not be done yet, etc.
    begin
      running_instances = app.running_instances
    rescue
      running_instances = 0
    end

    {
        running: app.running?,
        instances: app.total_instances,
        running_instances: running_instances,
    }
  end

  # Create app
  # space_guid = apps space guid
  # name = app name
  # instances = app number of instances value
  # memory = app memory value
  # domain_name = domain name that route belong to
  # host_name = app route
  # path = app path to directory containing app source
  # app_services = services to be bind to app
  # stack = apps stack if is specified in manifest
  # buildpack = apps buildpack if is specified in manifest
  # app_id = app sample id, which type is the app to be created
  #
  def create!(space_guid, name, instances, memory, domain_name, host_name, path, app_services, stack = nil, buildpack, app_id)
    info_ln("Pushing app '#{name}' ...")

    app_file_size_MB = (File.size(path) / (1024.0 * 1024)).round(2)
    client_token = @client.base.token
    client_target = @client.base.target

    space = @client.space(space_guid)

    new_app = @client.app
    new_app.space = space
    new_app.name = name
    new_app.total_instances = instances
    new_app.memory = memory
    new_app.stack = @client.stack_by_name(stack) if stack
    new_app.buildpack = buildpack

    if new_app.buildpack
      info("Using buildpack <b><a href='#{new_app.buildpack}' target='_blank'>#{new_app.buildpack}</a></b>")
    end

    info("Creating app '#{name}' with #{memory}MB memory and #{instances} instances...")

    if new_app.create!
      new_app_guid = new_app.guid

      if app_id != "asp_net_sql_sample"
        info("Uploading bits (#{ app_file_size_MB }MB)...")
        new_app.upload path
        ok_ln("OK")
      end

      info_ln("Setting up services ...")

      service_instances = ServiceInstances.new(client_token, client_target)

      app_services.each do |service|
        service_name = service[:name]

        info("  Creating service '#{service_name}'.")

        begin
          service_create = service_instances.create_service_by_names(service_name, space_guid, service[:plan] || 'free', service[:type])
          if service_create != false
            if app_id == "asp_net_sql_sample"
              value = write_app_config(path, service_create.name)

              #write and save the app config file
              File.open(path + "/Web.config", "w"){ |file| file.write(value.to_s) }
              ok("OK")

              info_ln("")
              info_ln("Uploading bits (#{ app_file_size_MB }MB)...")
              new_app.upload path
            end

            ok_ln("Done")
          else
            error_ln("Failed")
            warning_ln("    The service type does not exist.")
          end
        rescue => ex
          error_ln("Failed")
          warning_ln("    #{ex.message}")
        end


        app = @client.app(new_app_guid)

        info("  Binding service '#{service_name}'.")

        begin
          if service_create != false
            service_bind = service_instances.get_service_by_name(service_name, space_guid)
            app.bind(service_bind)
            ok_ln("Done")
          else
            error_ln("Failed")
            warning_ln("    The service does not exist")
          end
        rescue => ex
          error_ln("Failed")
          warning_ln("    #{ex.message}")
        end
      end

      domain = @client.domains.find { |domain|
        domain.name == domain_name
      }

      begin
        info("Setting up application route '#{name}.#{domain_name}'...")
        Library::Routes.new(client_token, client_target).create(new_app_guid, space_guid, domain.guid, host_name)
        ok_ln("Done")
      rescue => ex
        error_ln("Failed")
        warning_ln("    #{ex.message}")
      end
      begin
        info_ln("Starting the application...")
        new_app.start! do |response|
          new_app.stream_update_log(response) do |log_entry|
            info_ln("  #{log_entry.gsub(/\r/, '').gsub(/\n/, '<br/>')}")
          end
        end
      rescue => ex
        error_ln("Failed")
        warning_ln("    #{ex.message}")
      end
    end
    ok_ln("Complete!")
  rescue => ex
    error_ln(ex.message)
  end

  # Changes the service name in the Web.config file of "asp_net_sql_sample" app type
  #
  def write_app_config (path, service_name)

    #copy the config file with all the string keys set
    sample = File.read(path + "/config_sample/Web.config")
    config = File.open(path + "/Web.config", "w"){ |file| file << sample.to_s }

    #open and change the app config file according to the sample config file
    config = File.read(path + "/Web.config")
    replacement = config.gsub("SERVICE_NAME", service_name)
    return replacement
  end

  # Update app details with new data
  # app_name = app name to be updated
  # state = apps state, after the app is updated will be left in the same state
  # instances = app new number of instances value
  # memory = app new memory value
  # services = app new services to be bind
  # urls = app new routes to be bind
  # binding_object = app new route to be created and bind
  # current_space = apps space guid
  # apps_list = apps list
  #
  def update(app_name, state, instances, memory, services, urls, binding_object, current_space, apps_list)
    #cloning the app object
    app = nil
    apps_list.each do |app_item|
      app = app_item.dup if app_item.name == app_name
    end

    app_guid = app.guid
    application = @client.app(app_guid)

    #modify app details
    info_ln("Setting up #{instances} instances for the app, each with #{memory}MB ...")

    application.total_instances = instances
    application.memory = memory

    #service bindings
    info_ln("Updating service bindings ...")
    parsed_services = JSON.parse(services)
    app_services = app.services
    parsed_services.each do |service|
      service_name = service["name"]
      element = app_services.find{ |serv| serv.name == service_name }

      if element == nil
        begin
          info("  Binding service '#{service_name} ... ")
          bind_app_services(application, service['guid'])
          ok_ln("OK")
        rescue => ex
          error_ln("Failed")
          warning_ln("    #{ex.message}")
        end
      end
    end

    app_services.each do |service|
      service_name = service.name
      element = parsed_services.find { |serv| serv['name'] == service_name }
      if element == nil
        begin
          info("  Unbinding service '#{service_name} ... ")
          unbind_app_services(application, service.guid)
          ok_ln("OK")
        rescue => ex
          error_ln("Failed")
          warning_ln("    #{ex.message}")
        end
      end
    end

    #url bindings
    info_ln("Updating URL bindings ...")
    parsed_urls = JSON.parse(urls)
    app_uris = app.uris
    parsed_urls.each do |url|
      url_host = url["host"]
      element = app_uris.find{ |url| url.host == url_host && url.domain == url['domain'] }
      if element == nil
        begin
          info("  Binding url '#{url_host}' ...")
          binding_object.create(app_guid, current_space, url['domain_guid'], url_host)
          ok_ln("OK")
        rescue => ex
          error_ln("Failed")
          warning_ln("    #{ex.message}")
        end
      end
    end


    app_uris.each do |uri|
      uri_host = uri.host
      element = parsed_urls.find { |url| url['host'] == uri_host }
      if element == nil
        begin
          info("  Unbinding url '#{uri_host}' ...")
          unbind_app_url(application, uri_host, uri.domain)
          ok_ln("OK")
        rescue => ex
          error_ln("Failed")
          warning_ln("    #{ex.message}")
        end
      end
    end

    info_ln("#{app_name} is now being updated ...")
    #applying the current state

    if state == 'true'
      begin
        info("Starting the app ...")
        application.stop!
        application.start!
        ok_ln("OK")
      rescue => ex
        error_ln("Failed")
        warning_ln("  #{ex.message}")
      end
    else
      begin
        info("Stopping the app ...")
        application.stop!
        ok_ln("OK")
      rescue => ex
        error_ln("Failed")
        warning_ln("  #{ex.message}")
      end
    end

    begin
      info("Applying changes ...")
      application.update!
      ok_ln("OK")
    rescue => ex
      error_ln("Failed")
      warning_ln("    #{ex.message}")
    end

  end

  # Deletes an app
  # app_guid = app guid to be deleted
  #
  def delete(app_guid)

    app = @client.app(app_guid)

    if app
      app.delete!
    end
  end


  private

  # Adds a app - service instance binding
  # app = cc API app object to which the service instance is bind
  # service_instance_guid = the service instance guid to be bind
  #
  def bind_app_services(app, service_instance_guid)
    service_instance = @client.service_instance(service_instance_guid)
    service_binding = @client.service_binding
    service_binding.app = app
    service_binding.service_instance = service_instance
    app.bind(service_instance)

  end

  # Removes a app - service instance binding
  # app = cc API app object from which the service instance is unbind
  # service_instance_guid = the service instance guid to be unbind
  #
  def unbind_app_services(app, service_instance_guid)
    service_instance = @client.service_instance(service_instance_guid)
    app.unbind(service_instance)

  end

  # Removes a app - route binding
  # app = cc API app object from which the route is unbind
  # host = the route to be unbind
  # domain = the domain that route belong to
  #
  def unbind_app_url(app, host, domain)
    route = @client.routes.find { |route| route.host == host && route.domain.name == domain }
    app.remove_route(route)

  end

  # Data holder for the tile displayed in organization/space/apps tab
  # name = name of the app
  # guid =  apps guid
  # stack = apps stack
  # state = state of the app
  # services = list of services
  # uris = list of apps url
  # instances = apps instances
  # memory = app memory
  #
  class Application
    attr_reader :name, :guid, :stack, :state, :services, :uris, :instances, :memory

    def initialize(name, guid, stack, state, services, uris, instances, memory)
      @name = name
      @guid = guid
      @stack = stack
      @state = state
      @services = services
      @uris = uris
      @instances = instances
      @memory = memory
    end
  end

  # Data holder for the tile displayed in organization/space/domains routes tab
  # host = name of the host (app route)
  # domain = domain under which the app will be routed
  class Url
    attr_reader :host, :domain

    def initialize(host, domain)
      @host = host
      @domain = domain
    end
  end

end
