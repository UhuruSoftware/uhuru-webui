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
  def create!(org_guid, space_guid, name, instances, memory, domain_name, host_name, path, app_services, stack=nil)
    info_ln("Pushing app '#{name}' ...")

    space = @client.space(space_guid)

    new_app = @client.app
    new_app.space = space
    new_app.name = name
    new_app.total_instances = instances
    new_app.memory = memory
    new_app.stack = @client.stack_by_name(stack) if stack

    info("Creating app '#{name}' with #{memory}MB memory and #{instances} instances...")

    if new_app.create!
      ok_ln("OK")

      info("Uploading bits (#{ File.size(path) / (1024 * 1024) }MB)...")

      new_app.upload path

      ok_ln("OK")

      info_ln("Setting up services ...")

      app_services.each do |service|

        info("  Creating service '#{service[:name]}'.")

        begin
          service_db_name = ServiceInstances.new(@client.base.token, @client.target).create_service_by_names(service[:name], space_guid, service[:plan] || 'free', service[:type])
          ok_ln("Done")
        rescue => e
          error_ln("Failed")
          warning_ln("    #{e.message}")
        end

        app = @client.apps.find { |a| a.name == name }

        info("  Binding service '#{service[:name]}'.")

        begin
          app.bind(service_db_name)
          ok_ln("Done")
        rescue => e
          error_ln("Failed")
          warning_ln("    #{e.message}")
        end
      end

      domain = @client.domains.find { |d|
        d.name == domain_name
      }

      begin
        info("Setting up application route '#{name}.#{domain_name}'...")
        Library::Routes.new(@client.base.token, @client.target).create(name, space_guid, domain.guid, host_name)
        ok_ln("Done")
      rescue => e
        error_ln("Failed")
        warning_ln("    #{e.message}")
      end
      begin
        info("Starting the application...")
        new_app.start!
        ok_ln("OK")
      rescue => e
        error_ln("Failed")
        warning_ln("    #{e.message}")
      end
    end
    ok_ln("Complete!")
  rescue => e
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

    if state == 'true'
      begin
        info("Starting the app ...")
        start_app(app_name)
        ok_ln("OK")
      rescue => e
        error_ln("Failed")
        warning_ln("  #{e.message}")
      end
    else
      begin
        info("Stopping the app ...")
        stop_app(app_name)
        ok_ln("OK")
      rescue => e
        error_ln("Failed")
        warning_ln("  #{e.message}")
      end
    end

    #modify app details
    info_ln("Setting up #{instances} instances for the app, each with #{memory}MB ...")
    application = @client.apps.find { |a| a.name == app_name }
    application.total_instances = instances
    application.memory = memory

    #service bindings
    info_ln("Updating service bindings ...")
    JSON.parse(services).each do |service|
      element = app.services.find{ |s| s.name == service['name'] }

      if element == nil
        begin
          info("  Binding service '#{service['name']} ... ")
          bind_app_services(app_name, service['name'])
          ok_ln("OK")
        rescue => e
          error_ln("Failed")
          warning_ln("    #{e.message}")
        end
      end
    end

    app.services.each do |service|
      element = JSON.parse(services).find { |s| s['name'] == service.name }
      if element == nil
        begin
          info("  Unbinding service '#{service['name']} ... ")
          unbind_app_services(app_name, service.name)
          ok_ln("OK")
        rescue => e
          error_ln("Failed")
          warning_ln("    #{e.message}")
        end
      end
    end

    #url bindings
    info_ln("Updating URL bindings ...")
    JSON.parse(urls).each do |url|
      element = app.uris.find{ |u| u.host == url['host'] && u.domain == url['domain'] }
      if element == nil
        begin
          info("  Binding url '#{url['host']}' ...")
          binding_object.create(app_name, current_space, url['domain_guid'], url['host'])
          ok_ln("OK")
        rescue => e
          error_ln("Failed")
          warning_ln("    #{e.message}")
        end
      end
    end


    app.uris.each do |uri|
      element = JSON.parse(urls).find { |u| u['host'] == uri.host }
      if element == nil
        begin
          info("  Unbinding url '#{url['host']}' ...")
          unbind_app_url(app_name, uri.host, uri.domain)
          ok_ln("OK")
        rescue => e
          error_ln("Failed")
          warning_ln("    #{e.message}")
        end
      end
    end

    begin
      info("Applying changes ...")
      application.update!
      ok_ln("OK")
    rescue => e
      error_ln("Failed")
      warning_ln("    #{e.message}")
    end

  end

  def delete(app_name)

    app = @client.app_by_name(app_name)

    #app = @client.find { |a| a.name == app_name }

    if app
      app.delete!
    end
  end


 private

  def start_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.start!
  end

  def stop_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.stop!
  end

  def bind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }
    service_binding = @client.service_binding
    service_binding.app = app
    service_binding.service_instance = service_instance
    app.bind(service_instance)

  end

  def unbind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }
    app.unbind(service_instance)

  end

  def unbind_app_url(app_name, host, domain)
    app = @client.apps.find { |a| a.name == app_name }
    route = @client.routes.find { |r| r.host == host && r.domain.name == domain }
    app.remove_route(route)

  end

  class Application
    attr_reader :name, :guid, :stack, :state, :services, :uris, :instances, :memory, :running, :running_instances

    def initialize(name, guid, stack, state, services, uris, instances, memory, running, running_instances)
      @name = name
      @guid = guid
      @stack = stack
      @state = state
      @services = services
      @uris = uris
      @instances = instances
      @memory = memory
      @running = running
      @running_instances = running_instances
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
