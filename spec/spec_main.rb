$:.unshift(File.expand_path("../../lib", __FILE__))

require 'rubygems'
require 'rspec'
require 'vcap/common'
require 'vcap/config'
require './lib/config'

require './lib/email'
require './lib/readapps'
require './lib/encryption'

require './lib/users_setup'
require './lib/users'
require './lib/organizations'
require './lib/spaces'
require './lib/applications'
require './lib/service_instances'
require './lib/domains'
require './lib/routes'

# defining constants for the spec tests
USER = 'marius.ivan@uhurusoftware.com'
PASSWORD = 'passpass'
ADMIN_USER = 'admin'
ADMIN_PASSWORD = 'password1234!'

ORGANIZATION_NAME = 'SOME_ORGANIZATION'
NEW_ORGANIZATION_NAME = 'SOME_ORGANIZATION_2'
SPACE_NAME = 'SOME_SPACE'
NEW_SPACE_NAME = 'SOME_SPACE_2'
DOMAIN_NAME = 'somedomain.net'


module Mocking
  # a class used to login the user and create the necessary objects for testing
  class Initializing
    attr_reader :user, :target, :config

    def initialize
      config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)
      @config = Uhuru::Webui::Config.from_file(config_file)
      @target = @config[:cloud_controller_url]
      user_login = UsersSetup.new(@config)
      @user = user_login.login(USER, PASSWORD)
    end

    # method used to clean up the tests organizations
    def clean_previous_tests
      orgs = Library::Organizations.new(@user.token, @target)

      # check if the organization exists or not
      org = orgs.get_organization_by_name(ORGANIZATION_NAME)
      if org != nil
        orgs.delete(@config, org.guid)
      end

      # check if the modified organization exists or not
      org = orgs.get_organization_by_name(NEW_ORGANIZATION_NAME)
      if org != nil
        orgs.delete(@config, org.guid)
      end
    end
  end
end



#$orgs = Library::Organizations.new($user.token, $target)
#$space = Library::Spaces.new($user.token, $target)
#$domains = Library::Domains.new($user.token, $target)
#
#org_guid = nil
#space_guid = nil
#begin
#  org_guid = $orgs.create($config, ORGANIZATION_NAME, $user.guid)
#  space_guid = $space.create(org_guid, SPACE_NAME)
#rescue CFoundry::OrganizationNameTaken => ex
#  puts ex.message
#  puts 'Attempting to remove the organization and recreate it clean ...'
#  $orgs.delete($config, $orgs.get_organization_by_name(ORGANIZATION_NAME).guid)
#  puts 'Organization removed successfully.'
#  org_guid = $orgs.create($config, ORGANIZATION_NAME, $user.guid)
#  space_guid = $space.create(org_guid, SPACE_NAME)
#end
#
#created = $domains.create(DOMAIN_NAME, org_guid, true, space_guid) # the domain wildcard is boolean


