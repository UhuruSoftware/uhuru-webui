require 'cfoundry'
require 'config'

class ServiceInstances

  def initialize(token, target)
    @client = CFoundry::V2::Client.new(target, token)
  end

  def create_service_instance(name, space_guid, plan, type)
    service = @client.services.select{ |s| s.label == type }
    service_plan = nil

    @client.service_plans_by_service_guid(service.first.guid).each do |current_plan|
      if current_plan.name == plan
        service_plan = current_plan
      end
    end

    service_instance = @client.managed_service_instance
    service_instance.name = name
    service_instance.service_plan = service_plan
    service_instance.space = @client.space(space_guid)

    service_instance.create!
    service_instance

  rescue Exception => e
    return e
  end

  def read_service_plans()
    @client.service_plans
  end

  def read_service_types()
    types = []
    @client.services.each do |type|
      types << type.label
    end

    types
  end

  def delete(service_instance_guid)
    service_instance = @client.service_instance(service_instance_guid)
    service_instance.service_bindings.each do |s|
      s.delete!
    end

    service_instance.delete!

  rescue Exception => e
    return e
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