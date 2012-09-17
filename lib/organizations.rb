$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require "uhuru_config"

class Organizations

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def readAll
    organizationslist = []
    orgslist = @client.organizations

    orgslist.each do |org|
      organizationslist << Organization.new(org.name, 0, org.users.count, [], org.guid)
    end

    organizationslist
  end

  def getName(orgGuid)
    org = @client.organization(orgGuid)
    org.name

  end

  def create(name)
    neworg = @client.organization
    neworg.name = name
    neworg.create!

  rescue Exception => e
    puts e.inspect
  end

  def update(name, orgGuid)
    org = @client.organization(orgGuid)
    org.name = name
    org.update!

  rescue Exception => e
    puts e.inspect
  end

  def delete(orgGuid)
    org = @client.organization(orgGuid)
    org.delete!

  rescue Exception => e
    puts e.inspect
  end

  def readSpaces(orgGuid)
    spaceslist = []
    spaces = @client.organization(orgGuid).spaces

    spaces.each do |space|
      spaceslist << Spaces::Space.new(space.name, 0, space.apps.count, space.service_instances.count, space.guid)
    end

    spaceslist
  end

  def readOwners(orgGuid)
    userslist = []
    users = @client.organization(orgGuid).billing_managers

    users.each do |user|
      userslist << Users::User.new(user.email, '', false, user.guid)
    end

    userslist
  end

  def readDevelopers(orgGuid)
    userslist = []
    users = @client.organization(orgGuid).managers

    users.each do |user|
      userslist << Users::User.new(user.email, '', false, user.guid)
    end

    userslist
  end

  def readManagers(orgGuid)
    userslist = []
    users = @client.organization(orgGuid).auditors

    users.each do |user|
      userslist << Users::User.new(user.email, '', false, user.guid)
    end

    userslist
  end

  class Organization
    attr_reader :name, :cost, :members_count, :roles, :guid

    def initialize(name, cost, members, roles, guid)
      @name = name
      @cost = cost
      @members_count = members
      @roles = roles
      @guid = guid
    end
  end

end