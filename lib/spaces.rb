$:.unshift(File.join(File.dirname(__FILE__)))

require 'cfoundry'
require 'uhuru_config'

class Spaces

  def initialize(token)
    @client = CFoundry::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def get_name(space_guid)
    space = @client.space(space_guid)
    space.name

  end

  def isBillable(space_guid)
    false

  end

  def readBillingManagers(space_guid)
    billing_managers = @client.space(space_guid).auditors

    emails_list = "'#{billing_managers.map { |x| x.email }.join("','")}'"

  end

  def set_current_space(space_guid)
    space = nil
    unless space_guid != nil
      space = @client.space(space_guid)
    end

    @client.current_space = space

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def create(org_guid, name)

    org = @client.organization(org_guid)

    new_space = @client.space
    new_space.organization = org
    new_space.name = name
    if new_space.create!
      users_obj = Users.new(@client.token)
      users_obj.add_user_with_role_to_space(new_space.guid, @client.current_user.guid, ['owner'])

      new_space.guid
    end

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def update(name, space_guid)

    space = @client.space(space_guid)
    space.name = name
    space.update!

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def delete(space_guid)

    space = @client.space(space_guid)
    unless space.apps == 0
      space.apps.each do |app|
        app_gen = Applications.new(@client.base.token)
        app_gen.delete(app.name)
      end
    end

    unless space.service_instances.count == 0
      space.service_instances.each do |service|
        service_gen = ServiceInstances.new(@client.base.token)
        service_gen.delete(service.guid)
      end
    end

    space.delete!

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"

  end

  def read_apps(space_guid)
    apps_list = []
    apps = @client.space(space_guid).apps

    apps.each do |app|

      app_service_instances = []
      app.services.each do |s|
        type = s.service_plan.service.label
        app_service_instances << ServiceInstances::Service.new(s.name, type, s.guid)
      end

      app_uris = []
      app.routes.each do |r|
        app_uris << Applications::Url.new(r.host + "." + r.domain.name)
      end

      apps_list << Applications::Application.new(app.name, app.runtime.name, app.guid, app.state, app_service_instances, app_uris, app.total_instances, app.memory)
    end

    apps_list
  end

  def read_service_instances(space_guid)
    services_list = []
    services = @client.space(space_guid).service_instances

    services.each do |service|
      type = service.service_plan.service.label
      services_list << ServiceInstances::Service.new(service.name, type, service.guid)
    end

    services_list
  end

  class Space
    attr_reader :name, :cost, :apps_count, :services_count, :guid

    def initialize(name, cost, apps_count, services_count, guid)
      @name = name
      @cost = cost
      @apps = apps_count
      @services = services_count
      @guid = guid
    end
  end

end