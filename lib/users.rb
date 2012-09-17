$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require "uhuru_config"

class Users

  def initialize(token)
    @client = CFoundry::Client.new(UhuruConfig.cloud_controller_api, token)
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