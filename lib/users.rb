$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require "uhuru_config"

class Users

  def initialize(token)
    @client = CFoundry::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def create_user_add_to_org(org_guid, email)
    org = @client.organization(org_guid)

    user = @client.user
    user.guid = email
    if (user.create!)
      existing_users = org.users
      existing_users << @client.user(email)

      org.users = existing_users
    end

    org.update!
    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def add_user_to_org_with_role(org_guid, email, role) # to use from invite user

    org = @client.organization(org_guid)

    user = @client.user
    user.guid = email

    if (user.create!)

      existing_users = org.users
      existing_users << @client.user(email)

      org.users = existing_users

      case role
        when 'owner'
          existing_billing_managers = org.billing_managers
          existing_billing_managers << @client.user(email)

          org.billing_managers = existing_billing_managers
        when 'developer'
          existing_managers = org.managers
          existing_managerss << @client.user(email)

          org.managers = existing_managers
        when 'manager'
          existing_auditors = org.auditors
          existing_auditors << @client.user(email)

          org.auditors = existing_auditors
      end

      org.update!
    end

  rescue Exception => e
    puts "#{e.inspect}, #{e.backtrace}"
  end

  def delete(email)
    user = @client.user(email)
    user.delete!

  rescue Exception => e
    puts "#{e.inspect}, #{e.backtrace}"
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