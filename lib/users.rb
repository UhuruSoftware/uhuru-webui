$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require "uhuru_config"

class Users

  def initialize(token)
    @client = CFoundry::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def create_user(org_guid, is_admin)  # not working to create user, only from console

    #org =  @client.organization(org_guid)
    #guid = SecureRandom.uuid
    #
    #new_user = org.user(:guid => guid)
    #new_user.admin = is_admin
    #new_user.guid = guid
    #[:guid]
    #new_user.guid
    #new_user.create!

    rescue Exception => e
      puts e.inspect
  end

  def delete(user_guid)
    user = @client.user(user_guid)
    user.delete!

    rescue Exception => e
      puts e.inspect
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