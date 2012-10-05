$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require 'uhuru_config'

class Applications

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  #track cf to see how domains are managed and what is owning organization for a domain
  def read_organization_domains(org_guid)

    org = @client.organization(org_guid)
    org.domains
  end

  # parameters with default arguments (= nil) may be
  def create(org_guid, space_guid, name, runtime, framework, instances, memory, domain_name, path, service_plan_guid = nil)

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
        service_obj = ServiceInstances.new(@client.base.token)

        service_db = service_obj.create_service_instance(name + "DB", space_guid, service_plan_guid)
        new_app.bind(service_db)

        # can't be used for now, if maybe in the future for uhuru file system
        #service_fs = service_obj.create_service_instance(name + "FS", space_guid, "uhurufs_service_plan_guid")
        #new_app.bind(service_fs)
      end

      domain = @client.domains.find { |d|
           d.name == domain_name
      }

      route = @client.routes.find { |r|
           r.host == name && r.domain == domain
      }

      unless route
        route = @client.route

        route.host = name
        route.domain = domain
        route.organization = org
        route.create!
      end

      new_app.add_route(route)

      new_app.upload(path, true)
      new_app.start!
    end

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def start_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }

    app.start!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def stop_app(app_name)
    app = @client.apps.find { |a| a.name == app_name }

    app.stop!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def update(app_name, instances, memory)
    app = @client.apps.find { |a| a.name == app_name }

    app.total_instances = instances
    app.memory = memory

    app.update!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
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
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def bind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }

    service_binding = @client.service_binding
    service_binding.app = app
    service_binding.service_instance = service_instance

    app.bind(service_instance)

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def unbind_app_services(app_name, service_instance_name)
    app = @client.apps.find { |a| a.name == app_name }
    service_instance = @client.service_instances.find { |s| s.name == service_instance_name }

    app.bind(service_instance)

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  #track cf to see how app routes are managed and what is owning organization for a domain
  def bind_app_url(app_name, org_guid, domain_name, new_url)
    app = @client.apps.find { |a| a.name == app_name }

    domain = @client.domains.find { |d| d.name == domain_name }

    route = @client.routes.find { |r| r.host == new_url && r.domain == domain }

    unless route
       route = @client.route

       route.host = new_url
       route.domain = domain
       route.organization = @client.organization(org_guid)
       route.create!
    end

    app.add_route(route)
  end

  def unbind_app_url(app_name, domain_name, old_url)
    app = @client.apps.find { |a| a.name == app_name }
    domain = @client.domains.find { |d| d.name == domain_name }
    route = @client.routes.find { |r| r.host == old_url && r.domain == domain }

    app.remove_route(route)
  end

  class Application
    attr_reader :name, :runtime, :guid, :state, :services, :uris, :instances, :memory

    def initialize(name, runtime, guid, state, services, uris, instances, memory)
      @name = name
      @runtime = runtime
      @guid = guid
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

end