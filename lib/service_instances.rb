$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require 'uhuru_config'

class ServiceInstances

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end
  
  def create_service_instance(name, space_guid, service_plan_guid)
    
    space = @client.space(space_guid)
    service_plan = @client.service_plan(service_plan_guid)
    
    service = @client.service_instance
    service.name = name
    service.space = space
    service.service_plan = service_plan
    service.create!
    
    rescue Exception => e
      puts e.inspect
  end

  def delete(service_instance_guid)
    service_instance = @client.service_instance(service_instance_guid)
    service_instance.delete!

    rescue Exception => e
      puts e.inspect
  end
  
  class Service
    attr_reader :name, :type, :guid

    def initialize(name, type, guid)
      @name = name
      @type = type
      @guid = guid
    end
  end
end