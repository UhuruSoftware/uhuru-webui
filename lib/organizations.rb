require 'cfoundry'
require 'config'
require 'sinatra/base'

  module Library
    class Organizations

      def initialize(token, target)
        @client = CFoundry::V2::Client.new(target, token)
      end

      def read_all
        organizations_list = []
        orgs_list = @client.organizations

        orgs_list.each do |org|

          cost = 0
          org_billable = is_organization_billable?(org.guid)
          if org_billable
            cost = BillingHelper.compute_org_estimated_cost(org)
          end

          organizations_list << Organization.new(org.name, cost, org.users.count, [], org.guid, org_billable)

          # true should be replaced with org.billing_enabled when/if cfoundry gem will expose this attribute
        end

        organizations_list.sort! { |a, b| a.name.downcase <=> b.name.downcase }
      end

      def read_orgs_by_user(user_guid)
        orgs_list = @client.organizations.find { |o|
          users = o.users
          users.find { |u|
            u.guid == user_guid
          }
        }

        orgs_list
      end

      def get_organization_by_name(org_name)
        org = @client.organizations.find { |o|
          o.name == org_name
        }

        org
      rescue Exception => e
        raise "#{e.inspect}, #{e.backtrace}"
      end

      def get_name(org_guid)
        org = @client.organization(org_guid)
        org.name

      end

      def get_members_count(org_guid)
        org = @client.organization(org_guid)
        org.users.count

      end

      def set_current_org(org_guid)
        org = nil
        unless org_guid != nil
          org = @client.organization(org_guid)
        end

        @client.current_organization = org

      rescue Exception => e
        raise "#{e.inspect}"
      end

      def create(config, name, user_guid)

        token = @client.token

        user_setup_obj = UsersSetup.new(config)
        admin_token = user_setup_obj.get_admin_token

        # elevate user just to create organization
        @client.token = admin_token

        new_org = @client.organization
        new_org.name = name
        if new_org.create!
          users_obj = Users.new(@client.token, @client.target)
          users_obj.add_user_to_org_with_role(new_org.guid, user_guid, ['owner', 'billing'])

          # then put token back to the initial one
          @client.token = token
          new_org.guid
        end

      rescue Exception => e
        puts e
        puts 'create org method error'
        return 'error'
      end

      def update(name, org_guid)
        org = @client.organization(org_guid)
        org.name = name
        org.update!

      rescue Exception => e
        puts e
        puts 'update org method error'
        return 'error'
      end

      def delete(config, org_guid)
        token = @client.token

        user_setup_obj = UsersSetup.new(config)
        admin_token = user_setup_obj.get_admin_token

        # elevate user just to create organization
        @client.token = admin_token

        org = @client.organization(org_guid)
        unless org.spaces.count == 0
          org.spaces.each do |space|
            space_gen = Spaces.new(@client.token, @client.target)
            space_gen.delete(space.guid)
          end
        end

        deleted = org.delete!

        # then put token back to the initial one
        @client.token = token

        deleted
      rescue Exception => e
        puts e
        puts 'delete org method error'
        return 'error'
      end

      def read_spaces(org_guid)
        spaces_list = []
        spaces = @client.organization(org_guid).spaces

        spaces.each do |space|
          cost = 0
          if is_organization_billable?(org_guid)
            cost = BillingHelper.compute_space_estimated_cost(space)
          end
          spaces_list << Spaces::Space.new(space.name, cost, space.apps.count, space.service_instances.count, space.guid)
      end

        spaces_list
      end

      def read_owners(config, org_guid)
        user_setup_obj = UsersSetup.new(config)

        users_list = []
        users = @client.organization(org_guid).managers

        users.each do |user|
          username = user_setup_obj.get_username_from_guid(user.guid)
          users_list << Users::User.new(username, 'owner', false, user.guid)
        end

        users_list
      end

      def read_billings(config, org_guid)
        user_setup_obj = UsersSetup.new(config)

        users_list = []
        users = @client.organization(org_guid).billing_managers

        users.each do |user|
          username = user_setup_obj.get_username_from_guid(user.guid)
          users_list << Users::User.new(username, 'billing', false, user.guid)
        end

        users_list
      end

      def read_auditors(config, org_guid)
        user_setup_obj = UsersSetup.new(config)

        users_list = []
        users = @client.organization(org_guid).auditors

        users.each do |user|
          username = user_setup_obj.get_username_from_guid(user.guid)
          users_list << Users::User.new(username, 'auditor', false, user.guid)
        end

        users_list
      end

  def is_organization_billable?(org_guid)
    base_path = "#{@client.target}/v2/organizations/#{org_guid}"
    headers = {'Content-Type' => 'application/json', 'Authorization' => @client.token}

    response = HttpDirectClient.get("#{base_path}", :headers => headers)
    if response.request.last_response.code == '200'
      if JSON.parse(response.body)
        return JSON.parse(response.body)['entity']['billing_enabled']
      end
    end
  rescue Exception => e
    false
  end

  def make_organization_billable(org_guid)
    base_path = "#{@client.target}/v2/organizations/#{org_guid}"
    headers = {'Content-Type' => 'application/json', 'Authorization' => @client.token}
    attributes = {:billing_enabled => true}

        response = HttpDirectClient.put("#{base_path}", :headers => headers, :body => attributes.to_json)
        return true if response.request.last_response.code == '201'

      rescue Exception => e
        false
      end

      class Organization
        attr_reader :name, :cost, :members_count, :roles, :guid, :is_paid

        def initialize(name, cost, members, roles, guid, is_paid = false)
          @name = name
          @cost = cost
          @members_count = members
          @roles = roles
          @guid = guid
          @is_paid = is_paid
        end
      end

    end
end