require 'cfoundry'
require "config"

module Library
  class Users

    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    # roles is an array of roles ex: ['owner', 'billing', 'auditor']
    def add_user_to_org_with_role(org_guid, user_guid, roles)

      org = @client.organization(org_guid)

      user_exist = true
      user = @client.users.find { |u| u.guid == user_guid }
      unless user
        user_exist = create_user(user_guid)
      end

      if (user_exist)
        user_find = org.users.find { |u| u.guid == user_guid }

        unless user_find
          existing_users = org.users
          existing_users << @client.user(user_guid)
          org.users = existing_users
        end

        roles.each do |role|
          case role
            when 'owner'
              user_find = org.managers.find { |u| u.guid == user_guid }

              unless user_find
                existing_managers = org.managers
                existing_managers << @client.user(user_guid)

                org.managers = existing_managers
              end
            when 'billing'
              user_find = org.billing_managers.find { |u| u.guid == user_guid }

              unless user_find
                existing_billing_managers = org.billing_managers
                existing_billing_managers << @client.user(user_guid)

                org.billing_managers = existing_billing_managers
              end
            when 'auditor'
              user_find = org.auditors.find { |u| u.guid == user_guid }

              unless user_find
                existing_auditors = org.auditors
                existing_auditors << @client.user(user_guid)

                org.auditors = existing_auditors
              end
          end
        end

        org.update!
      end

    rescue Exception => e
      puts e
      puts 'add user method error (2nd method)(org)'
      return 'error'
    end

    # roles is an array of roles ex: ['owner', 'developer', 'auditor']
    def add_user_with_role_to_space(space_guid, user_guid, roles)
      space = @client.space(space_guid)

      user = @client.user(user_guid)

      if (user != nil)

        roles.each do |role|
          case role
            when 'owner'
              existing_managers = space.managers
              existing_managers << user

              space.managers = existing_managers
            when 'developer'
              existing_developers = space.developers
              existing_developers << user

              space.developers = existing_developers
            when 'auditor'
              existing_auditors = space.auditors
              existing_auditors << user

              space.auditors = existing_auditors
          end
        end

        space.update!
      end

    rescue Exception => e
      puts e
      puts 'add user method error (2nd method)(space)'
      return 'error'
    end

    #to be modified to search through uaa user names list
    def invite_user_with_role_to_org(config, username, org_guid, role)
      user_setup_obj = UsersSetup.new(config)
      user_guid = user_setup_obj.uaa_get_user_by_name(username)

      # if the user doesn't exist in the uaa, should create it but there are missing information (first name, last name, password)
      unless !user_guid
        add_user_to_org_with_role(org_guid, user_guid, [role])
      else
        puts 'add user method error (organization)'
        return 'error'
      end
    end

    def invite_user_with_role_to_space(config, username, space_guid, role)
      user_setup_obj = UsersSetup.new(config)
      user_guid = user_setup_obj.uaa_get_user_by_name(username)

      # if the user doesn't exist in the uaa, should create it but there are missing information (first name, last name, password)
      unless !user_guid
        add_user_with_role_to_space(space_guid, user_guid, [role])
      else
        puts 'add user method error (space)'
        return 'error'
      end
    end

    def check_user_org_roles(org_guid, user_guid, roles)
      org = @client.organization(org_guid)
      correct_roles = true

      roles.each do |role|
        case role
          when 'owner'
            user = org.managers.find { |u| u.guid == user_guid }
            if user != nil
              correct_roles = correct_roles && true if user != nil
            else
              return false
            end

          when 'billing'
            user = org.billing_managers.find { |u| u.guid == user_guid }
            if user != nil
              correct_roles = correct_roles && true if user != nil
            else
              return false
            end
          when 'auditor'
            user = org.auditors.find { |u| u.guid == user_guid }
            if user != nil
              correct_roles = correct_roles && true if user != nil
            else
              return false
            end
        end
      end

      correct_roles
    end

    def get_user_guid
      user = @client.current_user
      user.guid
    end

    # role is a string ex: 'owner', 'billing', 'auditor'
    def remove_user_with_role_from_org(org_guid, user_guid, role)
      org = @client.organization(org_guid)
      user = @client.user(user_guid)

      # if user have no roles in org will be removed also from table users
      remove_user = true

      case role
        when 'owner'
          user_find = org.managers.find { |u| u.guid == user_guid }
          remove_user = remove_user && true if user_find == nil

          existing_managers = org.managers
          existing_managers.delete(user)
          org.managers = existing_managers
        when 'billing'
          user_find = org.billing_managers.find { |u| u.guid == user_guid }
          remove_user = remove_user && true if user_find == nil

          existing_billing_managers = org.billing_managers
          existing_billing_managers.delete(user)
          org.billing_managers = existing_billing_managers
        when 'auditor'
          user_find = org.auditors.find { |u| u.guid == user_guid }
          remove_user = remove_user && true if user_find == nil

          existing_auditors = org.auditors
          existing_auditors.delete(user)
          org.auditors = existing_auditors
      end

      if (remove_user)
        existing_users = org.users
        existing_users.delete(user)
        org.users = existing_users
      end

      org.update!

    rescue Exception => e
      raise "delete user error-org" #"#{e.inspect}"
    end

     # role is a string ex: 'owner', 'developer', 'auditor'
    def remove_user_with_role_from_space(space_guid, user_guid, role)
      space = @client.space(space_guid)
      user = @client.user(user_guid)

      case role
        when 'owner'
          existing_managers = space.managers
          existing_managers.delete(user)
          space.managers = existing_managers
        when 'developer'
          existing_developers = space.developers
          existing_developers.delete(user)
          space.developers = existing_developers
        when 'auditor'
          existing_auditors = space.auditors
          existing_auditors.delete(user)
          space.auditors = existing_auditors
      end

      space.update!

    rescue Exception => e
      raise "delete user error-space" #"#{e.inspect}"
    end

    def user_exists(user_guid)
      user = @client.users.find { |u|
        u.guid == user_guid
      }
      if user == nil
        return false
      else
        return true
      end
    end

    private

    def create_user(user_guid)
      base_path = @client.target + '/v2/users'
      headers = {'Content-Type' => 'application/json', 'Authorization' => @client.token}
      attributes = {:guid => user_guid}

      response = HttpDirectClient.post("#{base_path}", :headers => headers, :body => attributes.to_json)
      return true if response.request.last_response.code == '201'

    rescue Exception => e
      false
      #raise "#{e.inspect}"
    end

    class User
      attr_reader :email, :role, :verified, :guid

      def initialize(email, role, verified, guid)
        @email = email
        @role = role
        @verified = verified
        @guid = guid
      end
    end

  end
end
