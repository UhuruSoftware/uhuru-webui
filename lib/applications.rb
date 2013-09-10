require 'cfoundry'
require 'config'

class Applications

  def initialize(token, target)
    @client = CFoundry::V2::Client.new(target, token)
  end

  #track cf to see how domains are managed and what is owning organization for a domain
  def read_organization_domains(org_guid)

    org = @client.organization(org_guid)
    org.domains
  end

  # parameters with default arguments (= nil) may be
  def create(org_guid, space_guid, name, instances, memory, domain_name, path, plan, app_services)

    space = @client.space(space_guid)

    new_app = @client.app
    new_app.space = space
    new_app.name = name
    new_app.total_instances = instances
    new_app.memory = memory

    if (new_app.create!)
      new_app.upload path

      unless !plan
        app_services.each do |service|
          begin
            service_db_name = ServiceInstances.new(@client.base.token, @client.target).create_service_instance(service[:name], space_guid, plan, service[:type])
          rescue
            error = AppError.new('service error', 'Could not create service for this app, create manually.')
            return error
          end

          app = @client.apps.find { |a| a.name == name }

          begin
            app.bind(service_db_name)
          rescue
            error = AppError.new('bind error', 'Could not bind the app to the service(s).')
            return error
          end
        end
      end

      domain = @client.domains.find { |d|
        d.name == domain_name
      }

      begin
        Library::Routes.new(@client.base.token, @client.target).create(name, space_guid, domain.guid, 'test_host_name')
      rescue
        error = AppError.new('route error', 'Could not map a route to this app, map it manually.')
        return error
      end
      begin
        new_app.start!
      rescue
        error = AppError.new('startapp error', 'Could not start the app, start it manually.')
        return error
      end
    end

  rescue Exception => e
    return e
  end

  def start_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.start!

  rescue Exception => e
    return e
  end

  def stop_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.stop!

  rescue Exception => e
    return e
  end

  def update(app_name, instances, memory)
    app = @client.apps.find { |a| a.name == app_name }
    app.total_instances = instances
    app.memory = memory
    app.update!

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

  def unbind_app_url(app_name, url)
    app = @client.apps.find { |a| a.name == app_name }
    route = @client.routes.find { |r| r.host + '.' + r.domain.name == url }
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
    attr_reader :url

    def initialize(url)
      @url = url
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