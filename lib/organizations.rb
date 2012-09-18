$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require "uhuru_config"

class Organizations

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def read_all
    organizations_list = []
    orgs_list = @client.organizations

    orgs_list.each do |org|
      organizations_list << Organization.new(org.name, 0, org.users.count, [], org.guid)
    end

    organizations_list
  end

  def get_name(org_guid)
    org = @client.organization(org_guid)
    org.name

  end

  def create(name)
    new_org = @client.organization
    new_org.name = name
    new_org.create!

  rescue Exception => e
    puts e.inspect
  end

  def update(name, org_guid)
    org = @client.organization(org_guid)
    org.name = name
    org.update!

  rescue Exception => e
    puts e.inspect
  end

  def delete(org_guid)
    org = @client.organization(org_guid)
    org.delete!

  rescue Exception => e
    puts e.inspect
  end

  def read_spaces(org_guid)
    spaces_list = []
    spaces = @client.organization(org_guid).spaces

    spaces.each do |space|
      spaces_list << Spaces::Space.new(space.name, 0, space.apps.count, space.service_instances.count, space.guid)
    end

    spaces_list
  end

  def read_owners(org_guid)
    users_list = []
    users = @client.organization(org_guid).billing_managers

    users.each do |user|
      users_list << Users::User.new(user.email, '', false, user.guid)
    end

    users_list
  end

  def read_developers(org_guid)
    users_list = []
    users = @client.organization(org_guid).managers

    users.each do |user|
      users_list << Users::User.new(user.email, '', false, user.guid)
    end

    users_list
  end

  def read_managers(org_guid)
    users_list = []
    users = @client.organization(org_guid).auditors

    users.each do |user|
      users_list << Users::User.new(user.email, '', false, user.guid)
    end

    users_list
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