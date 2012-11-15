require 'cfoundry'
require "config"
require 'http_direct_client'

class Users

  def initialize(token, target)
    @client = CFoundry::Client.new(target, token)
  end

  def create_user_add_to_org(org_guid, user_guid)
    org = @client.organization(org_guid)

    user = @client.user
    user.guid = user_guid
    if (user.create!)
      existing_users = org.users
      existing_users << @client.user(user_guid)

      org.users = existing_users
    end

    org.update!
  rescue Exception => e
    raise "#{e.inspect}"
  end

  # roles is an array of roles ex: ['owner', 'manager']
  def add_user_to_org_with_role(org_guid, user_guid, roles) # to use from invite user

    org = @client.organization(org_guid)

    user_exist = true
    user = @client.users.find {|u| u.guid == user_guid}
    unless user
      user_exist = create_user(user_guid)
    end

    if (user_exist)

      existing_users = org.users
      existing_users << @client.user(user_guid)

      org.users = existing_users

      roles.each do |role|
        case role
          when 'owner'
            existing_managers = org.managers
            existing_managers << @client.user(user_guid)

            org.managers = existing_managers
          when 'billing'
            existing_billing_managers = org.billing_managers
            existing_billing_managers << @client.user(user_guid)

            org.billing_managers = existing_billing_managers
          when 'auditor'
            existing_auditors = org.auditors
            existing_auditors << @client.user(user_guid)

            org.auditors = existing_auditors
        end
      end

      org.update!
    end

  rescue Exception => e
    false
    raise "#{e.inspect}"
  end

  # roles is an array of roles ex: ['owner', 'manager']
  def add_user_with_role_to_space(space_guid, user_guid, roles) # to use from invite user

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
    false
    raise "#{e.inspect}, #{e.backtrace}"
  end

  def get_user_guid
    user = @client.current_user
    user.guid
  end

  def delete(user_guid)
    user = @client.user(user_guid)
    user.delete!

  rescue Exception => e
    raise "#{e.inspect}"
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