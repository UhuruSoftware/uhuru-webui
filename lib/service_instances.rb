require 'cfoundry'
require 'config'

class ServiceInstances

  def initialize(token, target)
    @client = CFoundry::V2::Client.new(target, token)
  end

  def create_service_by_names(name, space_guid, service_plan_name, service_type_name)
    service = @client.services.select{ |s| s.label == service_type_name }

    service_plan_id = @client.service_plans_by_service_guid(service.first.guid).each.find { |current_plan| current_plan.name == service_plan_name }.guid

    create_service_instance(name, space_guid, service_plan_id)
  end

  def create_service_instance(name, space_guid, service_plan_id)
    service_plan_instance = CFoundry::V2::ServicePlan.new(service_plan_id, @client)

    service_instance = @client.managed_service_instance
    service_instance.name = name
    service_instance.service_plan = service_plan_instance
    service_instance.space = @client.space(space_guid)

    service_instance.create!
    service_instance
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
  end

  class Service
    attr_reader :name, :type, :guid, :plan

    def initialize(name, type, guid, plan)
      @name = name
      @type = type
      @plan = plan
      @guid = guid
    end
  end
end