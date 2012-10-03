$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require 'uhuru_config'

class Applications

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def create(org_guid, space_guid, name, runtime, framework, instances, memory, domain_name, path)

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

  def delete(app_name)
    app = @client.apps.find { |a| a.name == app_name }
    app.delete!

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

  class Application
    attr_accessor :name, :runtime, :guid, :state, :services, :instances, :memory

    def initialize(name, runtime, guid, state, services, instances, memory)
      @name = name
      @runtime = runtime
      @guid = guid
      @state = state
      @services = services
      @instances = instances
      @memory = memory
    end
  end

end