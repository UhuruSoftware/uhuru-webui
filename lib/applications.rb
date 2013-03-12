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
  def create(org_guid, space_guid, name, runtime, framework, instances, memory, domain_name, path, service_plan_guid)

    org = @client.organization(org_guid)
    space = @client.space(space_guid)

    runtime_obj = @client.runtimes.find { |r|
      r.name == runtime
    }

    framework_obj = @client.frameworks.find { |f|
      f.name == framework
    }

    new_app = @client.app
    new_app.space = space
    new_app.runtime = runtime_obj
    new_app.framework = framework_obj
    new_app.name = name
    new_app.total_instances = instances
    new_app.memory = memory

    if (new_app.create!)

      unless !service_plan_guid
        service_obj = ServiceInstances.new(@client.base.token, @client.target)

        service_db = service_obj.create_service_instance(name + "DB", space_guid, service_plan_guid)
        new_app.bind(service_db)

        # can't be used for now, if maybe in the future for uhuru file system
        #service_fs = service_obj.create_service_instance(name + "FS", space_guid, "uhurufs_service_plan_guid")
        #new_app.bind(service_fs)
      end

      domain = @client.domains.find { |d|
        d.name == domain_name
      }

      routes_obj = Library::Routes.initialize_with_client(@client)
      routes_obj.create(name, space_guid, domain.guid, name)

      new_app.upload(path, true)
      new_app.start!
    end

  rescue Exception => e
    puts e
    puts 'create app method error'
    return 'error'
  end

  def start_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }

    app.start!

  rescue Exception => e
    puts e
    puts 'start app method error'
    return 'error'
  end

  def stop_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }

    app.stop!

  rescue Exception => e
    puts e
    puts 'stop app method error'
    return 'error'
  end

  def update(app_name, instances, memory)
    app = @client.apps.find { |a| a.name == app_name }

    app.total_instances = instances
    app.memory = memory

    app.update!

  rescue Exception => e
    puts e
    puts 'update app method error'
    return 'error'
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
    puts e
    puts 'delete app method error'
    return 'error'
  end

  def bind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }

    service_binding = @client.service_binding
    service_binding.app = app
    service_binding.service_instance = service_instance

    app.bind(service_instance)

  rescue Exception => e
    puts e
    puts 'bind service method error'
    return 'error'
  end

  def unbind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }

    app.bind(service_instance)

  rescue Exception => e
    puts e
    puts 'unbind service method error'
    return 'error'
  end

  def unbind_app_url(app_name, domain_name, old_url)
    app = @client.apps.find { |a| a.name == app_name }
    domain = @client.domains.find { |d| d.name == domain_name }
    route = @client.routes.find { |r| r.host == old_url && r.domain == domain }

    app.remove_route(route)

  rescue Exception => e
    puts e
    puts 'unbind uri method error'
    return 'error'
  end

  class Application
    attr_reader :name, :runtime, :guid, :state, :services, :uris, :instances, :memory, :production

    def initialize(name, runtime, guid, state, services, uris, instances, memory, production)
      @name = name
      @runtime = runtime
      @guid = guid
      @state = state
      @services = services
      @uris = uris
      @instances = instances
      @memory = memory
      @production = production
    end
  end

  class Url
    attr_reader :url

    def initialize(url)
      @url = url
    end
  end

end