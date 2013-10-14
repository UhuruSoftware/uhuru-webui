require 'cfoundry'
require 'config'

module Library
  class Spaces

    def initialize(token, target)
      @client = CFoundry::Client.get(target, token)
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
      emails_list
    end

    def set_current_space(space_guid)
      space = nil
      unless space_guid != nil
        space = @client.space(space_guid)
      end

      @client.current_space = space

    rescue Exception => e
      raise "#{e.inspect}"
    end

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

    def update(name, space_guid)

      space = @client.space(space_guid)
      space.name = name
      space.update!

    end

    def delete(space_guid)
      space = @client.space(space_guid)
      space.delete(:recursive => true)

    end

    def read_apps(space_guid)
      apps_list = []
      apps = @client.space(space_guid).apps

      apps.each do |app|

        app_service_instances = []
        app.services.each do |s|
          type = s.service_plan.service.label
          app_service_instances << ServiceInstances::Service.new(s.name, type, s.guid, "free")
        end

        app_uris = []
        app.routes.each do |r|
          app_uris << Applications::Url.new(r.host, r.domain.name)
        end

        apps_list << Applications::Application.new(app.name, app.guid, app.stack, app.state, app_service_instances, app_uris, app.total_instances, app.memory)

      end

      apps_list
    end

    def read_service_instances(space_guid)
      services_list = []
      services = @client.space(space_guid).service_instances

      services.each do |service|
        type = service.service_plan.service.label
        services_list << ServiceInstances::Service.new(service.name, type, service.guid, "free")
      end

      services_list
    end

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