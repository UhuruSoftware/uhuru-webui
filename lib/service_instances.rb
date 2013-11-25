require 'cfoundry'
require 'config'

#this class contains all the functionality that deals with the services inside of a specific space
class ServiceInstances

  def initialize(token, target)
    @client = CFoundry::V2::Client.new(target, token)
  end

  # method for checking if the service plan exist, if it exists the the create_service_instance method is called
  def create_service_by_names(name, space_guid, service_plan_name, service_type_name)
    service = @client.services.select{ |srv| srv.label == service_type_name }

    if service != []
      service_plan_id = @client.service_plans_by_service_guid(service.first.guid).each.find { |current_plan| current_plan.name == service_plan_name }.guid
      create_service_instance(name, space_guid, service_plan_id)
    else
      return false
    end
  end

  # method that creates the service and returns the service object
  def create_service_instance(name, space_guid, service_plan_id)
    service_plan_instance = CFoundry::V2::ServicePlan.new(service_plan_id, @client)
    service_instance = @client.managed_service_instance
    service_instance.name = name
    service_instance.service_plan = service_plan_instance
    service_instance.space = @client.space(space_guid)
    service_instance.create!
    service_instance
  end

  # returns the service name
  def get_service_by_name(name, space_guid)
    @client.service_instances_by_name(name).find {|srv| srv.space.guid = space_guid }
  end

  # return the service plans from the cloud controller
  def read_service_plans()
    @client.service_plans
  end

  # returns the service types from the cloud controller
  def read_service_types()
    types = []
    @client.services.each do |type|
      types << type.label
    end

    types
  end

  # removes the service from the cloud controller
  def delete(service_instance_guid)
    service_instance = @client.service_instance(service_instance_guid)
    service_instance.service_bindings.each do |s|
      s.delete!
    end

    service_instance.delete!
  end

  # Data holder for the service tile that will be displayed inside a space (visible in the services tab)
  # name = the service name
  # type = the service type (ex: 'mysql', 'mongodb', 'mssql')
  # plan = the plan (ex: 'free')
  # guid = id or guid of the service
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