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

    service = @client.service_instance
    service.name = name
    service.space = @client.space(space_guid)
    service.service_plan = @client.service_plan(service_plan_guid)
    service.create!

    service

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def read_service_plans()
    @client.service_plans

  end

  def delete(service_instance_guid)
    service_instance = @client.service_instance(service_instance_guid)
    service_instance.service_bindings.each do |s|
      s.delete!
    end

    service_instance.delete!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
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