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
    new_app.create!

  rescue Exception => e
    puts e.inspect
  end

  def delete(app_guid)
    app = @client.app(app_guid)
    app.delete!

    rescue Exception => e
      puts e.inspect
  end


  class Application
    attr_reader :name, :framework, :guid

    def initialize(name, framework, guid)
      @name = name
      @framework = framework
      @guid = guid
    end
  end

end