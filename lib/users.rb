require 'cfoundry'
require "config"

#this class contains all the functionality that deals with the users inside the cloud controller database
module Library
  class Users

    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    # adds a user to the clod inside a specific organization with a user guid and a user role
    def add_user_to_org_with_role(org_guid, user_guid, roles)
      org = @client.organization(org_guid)
      owner = org.managers.find { |user| user.guid == user_guid }
      billing = org.billing_managers.find { |user| user.guid == user_guid }
      auditor = org.auditors.find { |user| user.guid == user_guid }

      roles.each do |role|
        case role
          when 'owner'
            unless owner
              existing_managers = org.managers
              existing_managers << @client.user(user_guid)
              org.managers = existing_managers
            end
          when 'billing'
            unless billing
              existing_billing_managers = org.billing_managers
              existing_billing_managers << @client.user(user_guid)
              org.billing_managers = existing_billing_managers
            end
          when 'auditor'
            unless auditor
              existing_auditors = org.auditors
              existing_auditors << @client.user(user_guid)
              org.auditors = existing_auditors
            end
        end
      end

      #apparently cfoundry api doesn't manage org - users relationship
      existing_users = org.users
      existing_users << @client.user(user_guid)
      org.users = existing_users

      org.update!
    end

    # adds a user to the clod inside a specific space and organization with a user guid and a user role
    def add_user_with_role_to_space(space_guid, user_guid, roles)
      space = @client.space(space_guid)
      owner = space.managers.find { |usr| usr.guid == user_guid }
      developer = space.developers.find { |usr| usr.guid == user_guid }
      auditor = space.auditors.find { |usr| usr.guid == user_guid }

      roles.each do |role|
        case role
          when 'owner'
            unless owner
              org = @client.organization_by_space_guid(space_guid)
              org.add_user(@client.user(user_guid))
              org.update!

              existing_managers = space.managers
              existing_managers << @client.user(user_guid)
              space.managers = existing_managers
            end
          when 'developer'
            unless developer
              org = @client.organization_by_space_guid(space_guid)
              org.add_user(@client.user(user_guid))
              org.update!

              existing_developers = space.developers
              existing_developers << @client.user(user_guid)
              space.developers = existing_developers
            end
          when 'auditor'
            unless auditor
              org = @client.organization_by_space_guid(space_guid)
              org.add_user(@client.user(user_guid))
              org.update!

              existing_auditors = space.auditors
              existing_auditors << @client.user(user_guid)
              space.auditors = existing_auditors
            end
        end
      end

      space.update!
    end

    # a method that checks if the user is registered, active or inactive.
    # if the user is active it calls the add_user_to_org_with_role method and adds the user to the organization
    def invite_user_with_role_to_org(config, username, org_guid, role)
      user_setup_obj = UsersSetup.new(config)
      user_guid = user_setup_obj.uaa_get_user_by_name(username)
      admin_token = user_setup_obj.get_admin_token
      admin_user = Library::Users.new(admin_token, $cf_target)
      active_user = admin_user.get_user_from_ccng(user_guid)

      if user_guid
        if active_user
          add_user_to_org_with_role(org_guid, user_guid, [role])
        else
          raise IsNotActive.new('not active', 'The user you are trying to invite does not confirmed his account yet.')
        end
      else
        raise DoesNotExist.new('inexistent', 'Cannot find this e-mail address. Users have to register to the cloud before they can be invited to join an organization.')
      end
    end

    # a method that checks if the user is registered, active or inactive.
    # if the user is active it calls the add_user_with_role_to_space method and adds the user to the space
    def invite_user_with_role_to_space(config, username, space_guid, role)
      user_setup_obj = UsersSetup.new(config)
      user_guid = user_setup_obj.uaa_get_user_by_name(username)
      admin_token = user_setup_obj.get_admin_token
      admin_user = Library::Users.new(admin_token, $cf_target)
      active_user = admin_user.get_user_from_ccng(user_guid)

      if user_guid
        if active_user
          add_user_with_role_to_space(space_guid, user_guid, [role])
        else
          raise IsNotActive.new('not active', 'The user you are trying to invite does not confirmed his account yet.')
        end
      else
        raise DoesNotExist.new('inexistent', 'Cannot find this e-mail address. Users have to register to the cloud before they can be invited to join a space.')
      end
    end

    # a method that checks for the user role from a list of roles and a user guid (from an organization)
    def check_user_org_roles(org_guid, user_guid, roles)
      org = @client.organization(org_guid)
      correct_roles = true

      roles.each do |role|
        case role
          when 'owner'
            user = org.managers.find { |usr| usr.guid == user_guid }
            if user != nil
              correct_roles = correct_roles && true if user != nil
            else
              return false
            end
          when 'billing'
            user = org.billing_managers.find { |usr| usr.guid == user_guid }
            if user != nil
              correct_roles = correct_roles && true if user != nil
            else
              return false
            end
          when 'auditor'
            user = org.auditors.find { |usr| usr.guid == user_guid }
            if user != nil
              correct_roles = correct_roles && true if user != nil
            else
              return false
            end
        end
      end

      correct_roles
    end

    # this method is checking if the user is already added inside of an organization
    def any_org_roles?(config, org_guid, username)
      user_setup_obj = UsersSetup.new(config)
      user_guid = user_setup_obj.uaa_get_user_by_name(username)

      org = @client.organization(org_guid)

      owner = org.managers.find { |usr| usr.guid == user_guid }
      billing = org.billing_managers.find { |usr| usr.guid == user_guid }
      auditor = org.auditors.find { |usr| usr.guid == user_guid }

      owner != nil || billing != nil || auditor != nil
    end

    #returns the user guid
    def get_user_guid
      user = @client.current_user
      user.guid
    end

    # a method that deletes a user from an organization
    # role is a string ex: 'owner', 'billing', 'auditor'
    def remove_user_with_role_from_org(org_guid, user_guid, role)
      org = @client.organization(org_guid)
      user = @client.user(user_guid)

      case role
        when 'owner'
          existing_managers = org.managers
          existing_managers.delete(user)
          org.managers = existing_managers
        when 'billing'
          existing_billing_managers = org.billing_managers
          existing_billing_managers.delete(user)
          org.billing_managers = existing_billing_managers
        when 'auditor'
          existing_auditors = org.auditors
          existing_auditors.delete(user)
          org.auditors = existing_auditors
      end

      # if the last role from org is removed, user will be removed from table org_users too
      owner = org.managers.find { |usr| usr.guid == user_guid }
      billing = org.billing_managers.find { |usr| usr.guid == user_guid }
      auditor = org.auditors.find { |usr| usr.guid == user_guid }

      if (owner == nil && billing == nil && auditor == nil)
        existing_users = org.users
        existing_users.delete(user)
        org.users = existing_users
      end

      org.update!
    end

    # a method that deletes a user from a space
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
    end

    # checks if the user exists
    def user_exists(user_guid)
      user = @client.users.find { |usr|
        usr.guid == user_guid
      }
      if user == nil
        return false
      else
        return true
      end
    end

    # search a user inside the cloud controller database from a user guid
    def get_user_from_ccng(user_guid)
      @client.users.find { |user|
        user.guid == user_guid
      }
    end

    # Data holder for the user that will be displayed in the users tab from organizations and spaces pages
    # email = the username or the user email
    # role = the user role(depending on the location if it is space or organization)
    # verified = if the user credit card was verified
    # guid = the user id or guid
    class User
      attr_reader :email, :role, :verified, :guid

      def initialize(email, role, verified, guid)
        @email = email
        @role = role
        @verified = verified
        @guid = guid
      end
    end

    # a class design for custom user error => if the user does not exist (the user does not exist in the uaa database)
    class DoesNotExist < Exception
      attr_reader :message, :description

      def initialize(message, description)
        super(message)
        @message = message
        @description = description
      end
    end

    # a class design for the custom user error => if the user is not active (the user is not active if the account was created but it was not user yet)
    class IsNotActive < Exception
      attr_reader :message, :description

      def initialize(message, description)
        super(message)
        @message = message
        @description = description
      end
    end
  end
end