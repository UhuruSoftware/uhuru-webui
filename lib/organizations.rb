require 'cfoundry'
require "config"

class Organizations

  def initialize(token, target)
    @client = CFoundry::V2::Client.new(target, token)
  end

  def read_all
    organizations_list = []
    orgs_list = @client.organizations

    orgs_list.each do |org|
      organizations_list << Organization.new(org.name, 0, org.users.count, [], org.guid)
    end

    organizations_list.sort! { |a, b| a.name.downcase <=> b.name.downcase }
  end

  def get_organization_by_name(org_name)
    org = @client.organizations.find { |o|
      o.name == org_name
    }

    org
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
    raise "#{e.inspect}"
  end

  def update(name, org_guid)
    org = @client.organization(org_guid)
    org.name = name
    org.update!

  rescue Exception => e
    raise "#{e.inspect}"
  end

  def delete(org_guid)
    org = @client.organization(org_guid)
    unless org.spaces.count == 0
      org.spaces.each do |space|
        space_gen = Spaces.new(@client.token, @client.target)
        space_gen.delete(space.guid)
      end
    end

    org.delete!

  rescue Exception => e
    raise "#{e.inspect}"
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