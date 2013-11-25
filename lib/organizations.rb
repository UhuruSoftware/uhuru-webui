require 'cfoundry'
require 'config'
require 'sinatra/base'

module Library
  # Data layer containing methods to handle cc API Organization object
  class Organizations

    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    # Reads all organizations for an user, where the user has a role
    # user_guid = logged in user guid
    #
    def read_all(user_guid)
      organizations_list = []
      orgs_list = @client.organizations

      orgs_list.each do |org|
        owner = org.managers.find { |manager| manager.guid == user_guid }
        billing = org.billing_managers.find { |billing| billing.guid == user_guid }
        auditor = org.auditors.find { |auditor| auditor.guid == user_guid }

        if owner || billing || auditor
          organizations_list << Organization.new(org.name, 0, org.users.count, org.guid, false)
        end
      end

      organizations_list.sort! { |first_org, second_org| first_org.name.downcase <=> second_org.name.downcase }
    end

    # Gets the cc API org object by name
    # org_name = organization name
    #
    def get_organization_by_name(org_name)
      org = @client.organizations.find { |cc_org|
        cc_org.name == org_name
      }

      org
    rescue Exception => ex
      raise "#{ex.inspect}, #{ex.backtrace}"
    end

    # Gets the cc API org object by guid
    # org_guid = organization guid
    #
    def get_name(org_guid)
      org = @client.organization(org_guid)
      org.name
    end

    # Creates an organization
    # config = loaded config file, for some operations is required admin credentials
    # name = organization name
    # user_guid =  logged in user guid, when an organization is created, the logged in user will be added with owner
    #              and billing manager role
    #
    def create(config, name, user_guid)

      token = @client.token

      user_setup_obj = UsersSetup.new(config)
      admin_token = user_setup_obj.get_admin_token

      # elevate user just to create organization
      @client.token = admin_token

      new_org = @client.organization
      new_org.name = name
      if new_org.create!
        org_guid = new_org.guid
        users_obj = Users.new(admin_token, @client.target)
        users_obj.add_user_to_org_with_role(org_guid, user_guid, ['owner', 'billing'])

        # then put token back to the initial one
        @client.token = token
        org_guid
      end

    end

    # Updates an organization name
    # name = new organization name
    # org_guid = organization guid to be updated
    #
    def update(name, org_guid)
      org = @client.organization(org_guid)
      org.name = name
      org.update!
    end

    # Deleted an organization
    # config = loaded config file, for some operations is required admin credentials
    # org_guid = organization guid to be updated
    #
    def delete(config, org_guid)
      token = @client.token

      user_setup_obj = UsersSetup.new(config)
      admin_token = user_setup_obj.get_admin_token

      # elevate user just to delete organization
      @client.token = admin_token
      org = @client.organization(org_guid)
      deleted = org.delete(:recursive => true)

      # then put token back to the initial one
      @client.token = token
      deleted
    end

    # Reads all the spaces in an organization
    # org_guid = organization guid
    #
    def read_spaces(org_guid)
      spaces_list = []
      spaces = @client.organization(org_guid).spaces

      spaces.each do |space|
        spaces_list << Library::Spaces::Space.new(space.name, 0, space.apps.count, space.service_instances.count, space.guid)
      end

      spaces_list
    end

    # Reads the user list that have owner role in on organization
    # config = loaded config file, for some operations is required admin credentials
    # org_guid = organization guid to get owners
    #
    def read_owners(config, org_guid)
      user_setup_obj = UsersSetup.new(config)

      users_list = []
      users = @client.organization(org_guid).managers

      users.each do |user|
        user_guid = user.guid
        username = user_setup_obj.get_username_from_guid(user_guid)
        users_list << Users::User.new(username, 'owner', false, user_guid)
      end

      users_list
    end

    # Reads the user list that have billing manager role in on organization
    # config = loaded config file, for some operations is required admin credentials
    # org_guid = organization guid to get billing managers
    #
    def read_billings(config, org_guid)
      user_setup_obj = UsersSetup.new(config)

      users_list = []
      users = @client.organization(org_guid).billing_managers

      users.each do |user|
        user_guid = user.guid
        username = user_setup_obj.get_username_from_guid(user_guid)
        users_list << Users::User.new(username, 'billing', false, user_guid)
      end

      users_list
    end

    # Reads the user list that have auditor role in on organization
    # config = loaded config file, for some operations is required admin credentials
    # org_guid = organization guid to get auditors
    #
    def read_auditors(config, org_guid)
      user_setup_obj = UsersSetup.new(config)

      users_list = []
      users = @client.organization(org_guid).auditors

      users.each do |user|
        user_guid = user.guid
        username = user_setup_obj.get_username_from_guid(user_guid)
        users_list << Users::User.new(username, 'auditor', false, user_guid)
      end

      users_list
    end

    # Check to see if the organization with provided guid exist
    # org_guid = organization guid to check
    #
    def org_exists?(org_guid)
      org = @client.organization(org_guid)
      org.exists?
    end

    # Data holder for the tile displayed in organizations tab
    # name = name of the organization
    # cost =  organization computed cost
    # members_count = number of users that have a role in org
    # guid = organization guid
    # is_paid = a flag that tells if a organization is paid or not
    #
    class Organization
      attr_reader :name, :cost, :members_count, :guid, :is_paid

      def initialize(name, cost, members, guid, is_paid = false)
        @name = name
        @cost = cost
        @members_count = members
        @guid = guid
        @is_paid = is_paid
      end
    end

  end
end