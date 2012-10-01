$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require 'uhuru_config'

class Applications

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def create(space_guid, name, runtime_guid, framework_guid)

    space = @client.space(space_guid)
    runtime = @client.runtime(runtime_guid)
    framework = @client.framework(framework_guid)

    new_app = @client.app
    new_app.space = space
    new_app.runtime = runtime
    new_app.framework = framework
    new_app.name = name
    #new_app.state = state
    #new_app.services = services
    #new_app.instances = instances
    #new_app.memory = memory

    path = "/home/adauser/Desktop/testphpinfo"

    if (new_app.create!)
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

  def delete(app_guid)
    app = @client.app(app_guid)
    app.delete!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end


  class Application
    attr_accessor :name, :framework, :guid, :state, :services, :instances, :memory

    def initialize(name, framework, guid, state, services, instances, memory)
      @name = name
      @framework = framework
      @guid = guid
      @state = state
      @services = services
      @instances = instances
      @memory = memory
    end
  end

end