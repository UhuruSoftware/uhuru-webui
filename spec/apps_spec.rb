require 'spec_helper.rb'

describe 'Main tests for users apps' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    # prepare a new organization and space for testings
    @routes = Library::Routes.new(@testing_data.user.token, @testing_data.target)
    @domains = Library::Domains.new(@testing_data.user.token, @testing_data.target)
    @services = ServiceInstances.new(@testing_data.user.token, @testing_data.target)
    @org_guid = Library::Organizations.new(@testing_data.user.token, @testing_data.target).create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
    @space_guid = Library::Spaces.new(@testing_data.user.token, @testing_data.target).create(@org_guid, SPACE_NAME)

    #create domain
    @domains.create(DOMAIN_NAME, @org_guid, true, @space_guid) # the domain wildcard is boolean
    @service_guid = @services.create_service_by_names(SERVICE_NAME, @space_guid, 'free', 'mysql').guid

    #get the guid from the new domain
    organization = Library::Organizations.new(@testing_data.user.token, @testing_data.target).get_organization_by_name(ORGANIZATION_NAME)
    @domain_guid = organization.domains.find{|domain| domain.name == DOMAIN_NAME}.guid

    #create apps
    @apps = Applications.new(@testing_data.user.token, @testing_data.target)
    @apps_list = TemplateApps.read_collections
    @apps.start_feedback
    @create_app = nil

    # the stack and the buildpack were set to nil by default
    begin
      @create_app = @apps.create!(@space_guid, APP_NAME, 1, 128, DOMAIN_NAME, 'host_name', @apps_list['asp_net_razor_sample']['app_src'], @apps_list['asp_net_razor_sample']['service_type'], nil, nil, @apps_list['asp_net_razor_sample']['id'])
    rescue Exception => ex
      puts ex
    end

    @app = Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first
    @app_guid = Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.guid
    @current_app_list = []
    @current_app_list << @app
    @apps.close_feedback
  end

  it 'should have 1 app inside the space(the test app that was pushed)' do
    @app_guid.should_not == []
  end

  # there should be only one app inside the space
  it 'should get app status' do
    @apps.get_app_running_status(@app_guid).should_not == nil
  end


  #
  # update methods
  #
  it 'should update the app state to STARTED' do
    @apps.update(APP_NAME, 'true', 1, 128, '{}', '{}', @routes, @space_guid, @current_app_list)
    Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.state.should == 'STARTED'
  end

  it 'should update the app state to STOPPED' do
    @apps.update(APP_NAME, 'false', 1, 128, '{}', '{}', @routes, @space_guid, @current_app_list)
    Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.state.should == 'STOPPED'
  end

  it 'should update the app instances' do
    @apps.update(APP_NAME, 'true', 2, 128, '{}', '{}', @routes, @space_guid, @current_app_list)
    Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.instances.should == 2
  end

  it 'should update the app instances' do
    @apps.update(APP_NAME, 'true', 1, 256, '{}', '{}', @routes, @space_guid, @current_app_list)
    Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.memory.should == 256
  end

  it 'should update the app service bindings' do
    service = Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_service_instances(@space_guid).first

    service_list = "[{ \"name\": \"#{service.name}\", \"type\": \"#{service.type}\", \"plan\": \"#{service.plan}\", \"guid\": \"#{service.guid}\" }]"
    @apps.update(APP_NAME, 'true', 1, 256, service_list, '{}', @routes, @space_guid, @current_app_list)

    #read the app service bindings
    Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.services.should_not == []
  end

  it 'should update the app url bindings' do
    url_list = "[{ \"host\": \"#{ROUTE_NAME}\", \"domain\": \"#{DOMAIN_NAME}\", \"domain_guid\": \"#{@domain_guid}\" }]"
    @apps.update(APP_NAME, 'true', 1, 256, '{}', url_list, @routes, @space_guid, @current_app_list)

    #read the app url bindings
    Library::Spaces.new(@testing_data.user.token, @testing_data.target).read_apps(@space_guid).first.uris.should_not == []
  end


  it 'should delete the app' do
    @apps.delete(@app_guid).should == true
  end
end