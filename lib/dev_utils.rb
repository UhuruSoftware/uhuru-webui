$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'cfoundry'
require 'uhuru_config'

class DevUtils

  def self.test_token
    #"bearer eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEzNDkyNDgxNjMsInVzZXJfbmFtZSI6ImFAYSIsInNjb3BlIjpbImNsb3VkX2NvbnRyb2xsZXIucmVhZCIsImNsb3VkX2NvbnRyb2xsZXIud3JpdGUiLCJvcGVuaWQiLCJwYXNzd29yZC53cml0ZSJdLCJlbWFpbCI6ImFAYSIsImF1ZCI6WyJvcGVuaWQiLCJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiXSwianRpIjoiOTFhZDU5OTMtMDY5YS00NWU0LThjZmEtMThiMzNkNWJkNjgzIiwidXNlcl9pZCI6Ijg0YTZhMWYwLWFmNzItNDE1My1iM2FlLTU3NjNkN2IzN2FkYiIsImNsaWVudF9pZCI6InZtYyJ9.5ocBAJShZJIlAyAyscfs-Fk5y4l4ey9L4NRgTO3KpT8"
    #"bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6ImIzZDRlNDY5LWFiN2QtNDRlNy1iNTYwLTc2MzcwN2E5NWFiZiIsInJlc291cmNlX2lkcyI6WyJvcGVuaWQiLCJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiXSwiZXhwaXJlc19hdCI6MTM0ODg1NzkwNywic2NvcGUiOlsib3BlbmlkIl0sImVtYWlsIjoic3JlQHZtd2FyZS5jb20iLCJjbGllbnRfYXV0aG9yaXRpZXMiOlsiUk9MRV9VTlRSVVNURUQiXSwiZXhwaXJlc19pbiI6NDMyMDAsInVzZXJfYXV0aG9yaXRpZXMiOlsiUk9MRV9VU0VSIl0sInVzZXJfaWQiOiJzcmVAdm13YXJlLmNvbSIsImNsaWVudF9pZCI6InZtYyJ9.UbYYQK2crzr9c-MqSb-Y7XMDeeRg3MWMItM0IczKWz4"
    "bearer eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEzNDk0MzgxNDMsInVzZXJfbmFtZSI6InNyZUB2bXdhcmUuY29tIiwic2NvcGUiOlsiY2xvdWRfY29udHJvbGxlci5yZWFkIiwiY2xvdWRfY29udHJvbGxlci53cml0ZSIsIm9wZW5pZCIsInBhc3N3b3JkLndyaXRlIl0sImVtYWlsIjoic3JlQHZtd2FyZS5jb20iLCJhdWQiOlsib3BlbmlkIiwiY2xvdWRfY29udHJvbGxlciIsInBhc3N3b3JkIl0sImp0aSI6ImY0NWMwM2YwLTIxYjMtNDdlZC1hMzc0LWNjNjc4ZjM4MDAwYiIsInVzZXJfaWQiOiI3MDI1NWNhOC01ZWE4LTQxOWItOTJlMC0xOGU5ODEwMjc4ZWEiLCJjbGllbnRfaWQiOiJ2bWMifQ.XyM6d8CLP0SOwZqX79BuhlBjgqAICK03mfUuNlwmsRE"
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