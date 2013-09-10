#!/usr/bin/env ruby

$:.unshift(File.expand_path("../../lib", __FILE__))

require "rubygems"
require "steno"
require "config"
require "users_setup"

def parse_options
  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
    opts.on("-c", "--config [ARG]", "Node configuration File") do |opt|
      @config_file = opt
    end
    opts.on("-h", "--help", "Help") do
      puts opts
      exit
    end
  end.parse!
end

def configure
  @config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)
  parse_options
  $config = Uhuru::Webui::Config.from_file(@config_file)
  setup_logging

  @cloud_target = $config[:cloud_controller_url]
  @username = $config[:monitoring][:cloud_user]
  @password = $config[:monitoring][:cloud_password]
  @default_org = $config[:monitoring][:default_org]
  @default_space = $config[:monitoring][:default_space]
  @components = $config[:monitoring][:components]
end

def setup_logging
  steno_config = Steno::Config.to_config_hash($config[:logging])
  steno_config[:context] = Steno::Context::ThreadLocal.new
  Steno.init(Steno::Config.new(steno_config))
end

def logger
  @logger ||= Steno.logger("monitoring")
end

def bootstrap_monitoring
  configure

  # get monitoring user from uaa
  users_setup = UsersSetup.new($config)
  user = users_setup.uaa_get_user_by_name(@username)
  # create monitoring user in uaa if doesn't exist
  unless user
    uaac = users_setup.get_uaa_client

    emails = [@username]
    info = {userName: @username, password: @password, name: {givenName: "monitoring", familyName: "user"}}
    info[:emails] = emails.respond_to?(:each) ?
        emails.each_with_object([]) { |email, o| o.unshift({:value => email}) } :
        [{:value => (emails || name)}]

    user = uaac.add(:user, info)
  end

  user_id = user != nil ? user : user['id']
  admin_token = users_setup.get_admin_token

  client = CFoundry::V2::Client.new(@cloud_target, admin_token)
  # check if monitoring org exists
  org = client.organizations.find { |o|
    o.name == @default_org
  }
  # create monitoring org with admin privileges
  unless org
    new_org = client.organization
    new_org.name = @default_org
    if new_org.create!
      users_obj = Library::Users.new(client.token, client.target)
      users_obj.add_user_to_org_with_role(new_org.guid, user_id, ['owner', 'billing'])
    end
    org = new_org
  end
  # check if monitoring space exists
  space = client.spaces.find { |s|
    s.name == @default_space
  }
  # create monitoring space with admin privileges
  unless space
    new_space = client.space
    new_space.organization = org
    new_space.name = @default_space
    if new_space.create!
      users_obj = Library::Users.new(client.token, client.target)
      users_obj.add_user_with_role_to_space(new_space.guid, user_id, ['owner', 'developer'])
    end
  end

  # get existing service authorisation tokens
  existing_service_auth_tokens = []
  client.service_auth_tokens.each do |s|
    existing_service_auth_tokens << s.label
  end

  # add service authorisation tokens
  @components[:services].each do |s|
    service = s["name"]
    service.slice!("_node")
    if !existing_service_auth_tokens.include?(service)
      service_auth_token = client.service_auth_token
      service_auth_token.label = service
      service_auth_token.provider = "core"
      service_auth_token.token = s["token"]
      service_auth_token.create!
    end
  end
end

bootstrap_monitoring