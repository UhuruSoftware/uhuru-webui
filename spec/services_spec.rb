require 'spec_helper.rb'

describe 'Main tests for users services' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    # prepare a new organization and space for testings
    @services = ServiceInstances.new(@testing_data.user.token, @testing_data.target)
    @org_guid = Library::Organizations.new(@testing_data.user.token, @testing_data.target).create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
    @space_guid = Library::Spaces.new(@testing_data.user.token, @testing_data.target).create(@org_guid, SPACE_NAME)

    @service_guid = @services.create_service_by_names(SERVICE_NAME, @space_guid, 'free', 'mysql').guid
  end

  it 'should read the service plans' do
    @services.read_service_plans().should_not == []
  end

  it 'should read the service types' do
    @services.read_service_types().should_not == []
  end

  it 'should get the service by name' do
    @services.get_service_by_name(SERVICE_NAME, @space_guid).should_not == nil
  end

  it 'should delete the service instance' do
    @services.delete(@service_guid).should == true
  end
end

