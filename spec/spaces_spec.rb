require 'spec_helper'

describe 'Main tests for users organizations' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    @space = Library::Spaces.new(@testing_data.user.token, @testing_data.target)
    @org_guid = Library::Organizations.new(@testing_data.user.token, @testing_data.target).create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
    @space_guid = @space.create(@org_guid, SPACE_NAME)
  end

  it 'should test create space' do
    @space_guid.should_not == nil
  end

  it 'should retrieve a space name' do
    name = @space.get_name(@space_guid)
    name.should == SPACE_NAME
  end

  it 'should read all apps' do
    apps = @space.read_apps(@space_guid)
    apps.should == [] # there are no default apps present
  end

  it 'should read all service instances' do
    services = @space.read_service_instances(@space_guid)
    services.should == [] # there are no default services
  end

  it 'should read all owners' do
    owners = @space.read_owners(@testing_data.config, @space_guid)
    owners.should_not == []
  end

  it 'should read all developers' do
    developers = @space.read_developers(@testing_data.config, @space_guid)
    developers.should_not == [] # there are no default developers created
  end

  it 'should read all auditors' do
    auditors = @space.read_auditors(@testing_data.config, @space_guid)
    auditors.should == []
  end

  # update and delete the space tests after the previous tests were done
  # last methods are update and delete in order
  it 'should update the space name' do
    updated = @space.update(NEW_SPACE_NAME, @space_guid)
    updated.should_not == nil
  end

  it 'should delete the current space' do
    deleted = @space.delete(@space_guid)
    deleted.should_not == nil
  end
end
