$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require 'uhuru_config'

class Applications

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def create(spaceGuid, name, runtimeGuid, frameworkGuid)

    space = @client.space(spaceGuid)
    runtime = @client.runtime(runtimeGuid)
    framework = @client.framework(frameworkGuid)

    newapp = @client.app
    newapp.space = space
    newapp.runtime = runtime
    newapp.framework = framework
    newapp.name = name
    newapp.create!

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