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

    begin
      @create_app = @apps.create!(@space_guid, APP_NAME, 1, 128, DOMAIN_NAME, 'host_name', @apps_list['asp_net_razor_sample']['app_src'], @apps_list['asp_net_razor_sample']['service_type'], nil, @apps_list['asp_net_razor_sample']['buildpack'], @apps_list['asp_net_razor_sample']['id'])
    rescue Exception => ex
      puts ex
    end

    @apps.close_feedback
  end

  it 'should get app status' do
    #@apps.get_app_running_status(@create_app.guid)
  end

  it 'should update the app' do
    #@apps.update(app_name, state, instances, memory, services, urls, binding_object, @space_guid, @apps_list)
  end

  it 'should delete the app' do
    #@apps.delete(@create_app.guid)
  end

end