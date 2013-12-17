require './spec_helper.rb'

describe 'Main tests for users domains' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    # prepare a new organization and space for testings
    @routes = Library::Routes.new(@testing_data.user.token, @testing_data.target)
    @domains = Library::Domains.new(@testing_data.user.token, @testing_data.target)
    @org_guid = Library::Organizations.new(@testing_data.user.token, @testing_data.target).create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
    @space_guid = Library::Spaces.new(@testing_data.user.token, @testing_data.target).create(@org_guid, SPACE_NAME)

    #create domain
    @domains.create(DOMAIN_NAME, @org_guid, true, @space_guid) # the domain wildcard is boolean

    #get the guid from the new domain
    organization = Library::Organizations.new(@testing_data.user.token, @testing_data.target).get_organization_by_name(ORGANIZATION_NAME)
    @domain_guid = organization.domains.find{|domain| domain.name == DOMAIN_NAME}.guid

    #create the route
    @route_guid = @routes.create(nil, @space_guid, @domain_guid, @space_guid).guid
    #create(app_guid, space_guid, domain_guid, host = nil)
  end

  it 'should read the routes' do
    @routes.read_routes(@space_guid, @domain_guid).should_not == []
  end

  it 'should delete the route' do
    @routes.delete(@route_guid).should == true
  end

end


