require 'cfoundry'
require 'config'

#this class contains all the functionality that deals with the spaces inside of a specific organization
module Library
  class Spaces

    def initialize(token, target)
      @client = CFoundry::Client.get(target, token)
    end

    # returns the space name from the space object
    def get_name(space_guid)
      space = @client.space(space_guid)
      space.name
    end

    # creates a space inside an organization
    def create(org_guid, name)
      org = @client.organization(org_guid)

      new_space = @client.space
      new_space.organization = org
      new_space.name = name
      if new_space.create!
        users_obj = Users.new(@client.token, @client.target)
        users_obj.add_user_with_role_to_space(new_space.guid, @client.current_user.guid, ['owner', 'developer'])

        new_space.guid
      end
    end

    # a method designed to update a space name
    def update(name, space_guid)

      space = @client.space(space_guid)
      space.name = name
      space.update!
    end

    # permanently remove a space from a specific organization
    def delete(space_guid)
      space = @client.space(space_guid)
      space.delete(:recursive => true)
    end

    # reads and returns all apps from the given space
    def read_apps(space_guid)
      apps_list = []
      apps = @client.space(space_guid).apps

      apps.each do |app|
        app_service_instances = []
        app.services.each do |srv|
          type = srv.service_plan.service.label
          app_service_instances << ServiceInstances::Service.new(srv.name, type, srv.guid, srv.service_plan.name)
        end

        app_uris = []
        app.routes.each do |route|
          app_uris << Applications::Url.new(route.host, route.domain.name)
        end

        apps_list << Applications::Application.new(app.name, app.guid, app.stack, app.state, app_service_instances, app_uris, app.total_instances, app.memory)
      end

      apps_list
    end

    # reads and returns all services from a given space
    def read_service_instances(space_guid)
      services_list = []
      services = @client.space(space_guid).service_instances

      services.each do |service|
        type = service.service_plan.service.label
        services_list << ServiceInstances::Service.new(service.name, type, service.guid, service.service_plan.name)
      end

      services_list
    end

    # a method that reads all space owners
    def read_owners(config, space_guid)
      user_setup_obj = UsersSetup.new(config)
      users_list = []
      users = @client.space(space_guid).managers

      users.each do |user|
        username = user_setup_obj.get_username_from_guid(user.guid)
        users_list << Users::User.new(username, 'owner', false, user.guid)
      end

      users_list
    end

    # a method that reads all space developers
    def read_developers(config, space_guid)
      user_setup_obj = UsersSetup.new(config)
      users_list = []
      users = @client.space(space_guid).developers

      users.each do |user|
        username = user_setup_obj.get_username_from_guid(user.guid)
        users_list << Users::User.new(username, 'developer', false, user.guid)
      end

      users_list
    end

    # a method that reads all space auditors
    def read_auditors(config, space_guid)
      user_setup_obj = UsersSetup.new(config)
      users_list = []
      users = @client.space(space_guid).auditors

      users.each do |user|
        username = user_setup_obj.get_username_from_guid(user.guid)
        users_list << Users::User.new(username, 'auditor', false, user.guid)
      end

      users_list
    end

    # Data holder for the space tile that will be displayed inside an organization
    # name = the space name
    # cost = the current space monthly fee
    # apps_count = number of apps present inside the space
    # service_count = number of services present inside the space
    # guid = the space id or guid
    class Space
      attr_reader :name, :cost, :apps_count, :services_count, :guid

      def initialize(name, cost, apps_count, services_count, guid)
        @name = name
        @cost = cost
        @apps_count = apps_count
        @services_count = services_count
        @guid = guid
      end
    end
  end
end