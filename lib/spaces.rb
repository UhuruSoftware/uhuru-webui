$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'erb'
require 'cfoundry'
require 'uhuru_config'

class Spaces

  def initialize(token)
    @client = CFoundry::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def getName(spaceGuid)
    space = @client.space(spaceGuid)
    space.name

  end

  def isBillable(spaceGuid)
    false

  end

  def readBillingManagers(spaceGuid)
    billingManagers = @client.space(spaceGuid).auditors

    emailslist = "'#{billingManagers.map { |x| x.email }.join("','")}'"

  end

  def create(orgGuid, name)

    org = @client.organization(orgGuid)

    newspace = @client.space
    newspace.organization = org
    newspace.name = name
    newspace.create!

  rescue Exception => e
    puts e.inspect
  end

  def update(name, spaceGuid)

    space = @client.space(spaceGuid)
    space.name = name
    space.update!

  rescue Exception => e
    puts e.inspect

  end

  def delete(spaceGuid)

    space = @client.space(spaceGuid)
    space.delete!

  rescue Exception => e
    puts e.inspect

  end

  def readApps(spaceGuid)
    appslist = []
    apps = @client.space(spaceGuid).apps

    apps.each do |app|
      appslist << Applications::Application.new(app.name, app.framework, app.guid)
    end

    appslist
  end

  def readServiceInstances(spaceGuid)
    serviceslist = []
    services = @client.space(spaceGuid).service_instances

    services.each do |service|
      serviceslist << ServiceInstances::Service.new(service.name, service.framework, service.guid)
    end

    appslist
  end

  class Space
    attr_reader :name, :cost, :apps, :services, :guid

    def initialize(name, cost, apps, services, guid)
      @name = name
      @cost = cost
      @apps = apps
      @services = services
      @guid = guid
    end
  end

end