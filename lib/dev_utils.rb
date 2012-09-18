$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'cfoundry'
require 'uhuru_config'

class DevUtils

  def self.test_token
    "bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6ImIzZDRlNDY5LWFiN2QtNDRlNy1iNTYwLTc2MzcwN2E5NWFiZiIsInJlc291cmNlX2lkcyI6WyJvcGVuaWQiLCJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiXSwiZXhwaXJlc19hdCI6MTM0Nzk5OTQ3NSwic2NvcGUiOlsib3BlbmlkIl0sImVtYWlsIjoic3JlQHZtd2FyZS5jb20iLCJjbGllbnRfYXV0aG9yaXRpZXMiOlsiUk9MRV9VTlRSVVNURUQiXSwiZXhwaXJlc19pbiI6NDMyMDAsInVzZXJfYXV0aG9yaXRpZXMiOlsiUk9MRV9VU0VSIl0sInVzZXJfaWQiOiJzcmVAdm13YXJlLmNvbSIsImNsaWVudF9pZCI6InZtYyJ9.vSwAnidPpu-NEnqNjjHu_uDjHv9d6mtJJnPffcEEmVY"
  end

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def auth_service_token(label, provider, token)
    servauth = @client.service_auth_token
    servauth.label = label
    servauth.provider = provider
    servauth.token = token
    servauth.create!

    rescue Exception => e
      puts e.inspect
  end

  def create_service(label, url)

    service = @client.service
    service.label = label
    service.provider = 'core'
    service.description = label + ' service type'

    service.url = url
    service.version = '1.0'
    service.create!

    rescue Exception => e
      puts e.inspect
  end

  def createServicePlan(name, description, service_guid)

    service = @client.service(service_guid)

    service_plan = @client.service_plan
    service_plan.name = name
    service_plan.description = description
    service_plan.service = service
    service_plan.create!

    rescue Exception => e
      puts e.inspect
  end

end