require 'cfoundry'
require 'config'
require 'class_with_feedback'

class Applications < Uhuru::Webui::ClassWithFeedback

  def initialize(token, target)
    super()
    @client = CFoundry::V2::Client.new(target, token)
  end

  #track cf to see how domains are managed and what is owning organization for a domain
  def read_organization_domains(org_guid)

    org = @client.organization(org_guid)
    org.domains
  end

  # parameters with default arguments (= nil) may be
  def create!(org_guid, space_guid, name, instances, memory, domain_name, host_name, path, plan, app_services)
    info_ln("Pushing app '#{name}' ...")

    space = @client.space(space_guid)

    new_app = @client.app
    new_app.space = space
    new_app.name = name
    new_app.total_instances = instances
    new_app.memory = memory

    info("Creating app '#{name}' with #{memory}MB memory and #{instances} instances...")

    if new_app.create!
      ok_ln("OK")

      info("Uploading bits (#{ File.size(path) / (1024 * 1024) }MB)...")

      new_app.upload path

      ok_ln("OK")

      info_ln("Setting up services ...")

      unless !plan
        app_services.each do |service|

          info("  Creating service '#{service[:name]}'.")

          begin
            service_db_name = ServiceInstances.new(@client.base.token, @client.target).create_service_instance(service[:name], space_guid, plan, service[:type])
            ok_ln("Done")
          rescue
            error_ln("Failed")
            warning_ln("    Could not create service '#{service[:name]}' for this app. The app was created, try to create the service manually.")
          end

          app = @client.apps.find { |a| a.name == name }

          info("  Binding service '#{service[:name]}'.")

          begin
            app.bind(service_db_name)
            ok_ln("Done")
          rescue
            error_ln("Failed")
            warning_ln("    Could not bind the app to service '#{service[:name]}'. The app was created successfully, try binding the service manually.")
          end
        end
      end

      domain = @client.domains.find { |d|
        d.name == domain_name
      }


      begin
        info("Setting up application route '#{name}.#{domain_name}'...")
        Library::Routes.new(@client.base.token, @client.target).create(name, space_guid, domain.guid, host_name)
        ok_ln("Done")
      rescue
        error_ln("Failed")
        warning_ln("  Could not map route '#{name}.#{domain_name}'. The app was created successfully, try to map the route manually.")
      end
      begin
        info("Starting the application...")
        new_app.start!
        ok_ln("OK")
      rescue
        error_ln("Failed")
        warning_ln('  Could not start the app, try starting it manually.')
      end
    end
    ok_ln("Complete!")
  rescue Exception => e
    error_ln(e.message)
  end

  ####################    update app details new data    ###########################
  def update(app_name, state, instances, memory, services, urls, binding_object, current_space, apps_list)
    #cloning the app object
    app = nil
    apps_list.each do |a|
      app = a.name == app_name ? a.clone : nil
    end

    info_ln("#{app_name} is now being updated ...")
    #applying the current state
    if state == true
      start_app(app_name)
    else
      stop_app(app_name)
    end

    #modify app details
    info_ln("&nbsp;&nbsp;&nbsp;&nbsp;updating app details ...")
    application = @client.apps.find { |a| a.name == app_name }
    application.total_instances = instances
    info_ln("&nbsp;&nbsp;&nbsp;&nbsp;number of instances: #{instances} ... OK")
    application.memory = memory
    info_ln("&nbsp;&nbsp;&nbsp;&nbsp;memory(in MB): #{memory} ... OK")
    ok_ln("App details updated successfully!")

    #service bindings
    info_ln("Updating service bindings ...")
    JSON.parse(services).each do |service|
      element = app.services.find{ |s| s.name == service['name'] }
      if element == nil
        bind_app_services(app_name, service['name'])
        info_ln("&nbsp;&nbsp;&nbsp;&nbsp;the service <b>" + service['name'] + "</b> was successfully bound to <b>" + app_name + "</b>")
      end
    end

    app.services.each do |service|
      element = JSON.parse(services).find { |s| s['name'] == service.name }
      if element == nil
        unbind_app_services(app_name, service.name)
        info_ln("&nbsp;&nbsp;&nbsp;&nbsp;unbinding <b>" + service.name + "</b> from <b>" + app_name + "</b>")
      end
    end
    ok_ln("Service bindings updated successfully!")

    #url bindings
    info_ln("Updating URL bindings ...")
    JSON.parse(urls).each do |url|
      element = app.uris.find{ |u| u.host == url['host'] && u.domain == url['domain'] }
      if element == nil
        binding_object.create(app_name, current_space, url['domain_guid'], url['host'])
        info_ln("&nbsp;&nbsp;&nbsp;&nbsp;the url <b>" + url['host'] + '.' + url['domain'] + "</b> was successfully bound to <b>" + app_name + "</b>")
      end
    end

    app.uris.each do |uri|
      element = JSON.parse(urls).find { |u| u['host'] == uri.host }
      if element == nil
        unbind_app_url(app_name, uri.host, uri.domain)
        info_ln("&nbsp;&nbsp;&nbsp;&nbsp;unbinding <b>" + uri.host + '.' + uri.domain + "</b> from <b>" + app_name + "</b>")
      end
    end
    ok_ln("URL bindings updated successfully!")
    info_ln("Applying changes ...")

    application.update!
    ok_ln("The app was updated successfully!")

  rescue Exception => e
    return e
  end

  def delete(app_name)
    app = @client.apps.find { |a| a.name == app_name }

    unless !app
      routes = app.routes

      if app.delete!
        routes.each do |r|
          r.delete!
        end
      end
    end

  rescue Exception => e
    return e
  end


 private

  def start_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.start!
    return info_ln("App #{app_name} is started.")
  rescue Exception => e
    return error_ln(e)
  end

  def stop_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.stop!
    return info_ln("App #{app_name} is stopped.")
  rescue Exception => e
    return error_ln(e)
  end

  def bind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }
    service_binding = @client.service_binding
    service_binding.app = app
    service_binding.service_instance = service_instance
    app.bind(service_instance)

  rescue Exception => e
    return e
  end

  def unbind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }
    app.unbind(service_instance)

  rescue Exception => e
    return e
  end

  def unbind_app_url(app_name, host, domain)
    app = @client.apps.find { |a| a.name == app_name }
    route = @client.routes.find { |r| r.host == host && r.domain.name == domain }
    app.remove_route(route)

  rescue Exception => e
    return e
  end

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

  class Url
    attr_reader :host, :domain

    def initialize(host, domain)
      @host = host
      @domain = domain
    end
  end

  class AppError
    attr_reader :message, :description

    def initialize(message, description)
      @message = message
      @description = description
    end
  end

end
