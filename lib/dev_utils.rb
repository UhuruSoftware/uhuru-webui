$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'cfoundry'
require 'uhuru_config'

class DevUtils

  def self.test_token
    "bearer eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEzNTE2Njg0OTcsInVzZXJfbmFtZSI6InNyZUB2bXdhcmUuY29tIiwic2NvcGUiOlsiY2xvdWRfY29udHJvbGxlci5yZWFkIiwiY2xvdWRfY29udHJvbGxlci53cml0ZSIsIm9wZW5pZCIsInBhc3N3b3JkLndyaXRlIl0sImVtYWlsIjoic3JlQHZtd2FyZS5jb20iLCJhdWQiOlsib3BlbmlkIiwiY2xvdWRfY29udHJvbGxlciIsInBhc3N3b3JkIl0sImp0aSI6IjE0NjYxNWE3LTc0OGYtNDVkNy05NTFjLTMwZWNhOWJkN2RkOCIsInVzZXJfaWQiOiI3MDI1NWNhOC01ZWE4LTQxOWItOTJlMC0xOGU5ODEwMjc4ZWEiLCJjbGllbnRfaWQiOiJ2bWMifQ.DkUmz6r4fkTXP9r-6QiobDrkByiQi5nzaxg9eCbRFs0"
  end

  def initialize(token)
    @client = CFoundry::V2::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def auth_service_token(label, provider, token)
    serv_auth = @client.service_auth_token
    serv_auth.label = label
    serv_auth.provider = provider
    serv_auth.token = token
    serv_auth.create!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
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
      puts "#{e.inspect}, #{e.backtrace}"
  end

  def createServicePlan(name, description, service_guid)

    service = @client.service(service_guid)

    service_plan = @client.service_plan
    service_plan.name = name
    service_plan.description = description
    service_plan.service = service
    service_plan.create!

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
  end

end