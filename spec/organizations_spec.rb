require 'spec_main'

describe 'Main tests for users organizations' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    @orgs = Library::Organizations.new(@testing_data.user.token, @testing_data.target)
    @org_guid = @orgs.create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
  end

  it 'should test create organization' do
    @org_guid.should_not == nil
  end

  it 'should exist since is newly created' do
    exist = @orgs.org_exists?(@org_guid)
    exist.should == true
  end

  it 'should retrieve an organization name' do
    name = @orgs.get_name(@org_guid)
    name.should == ORGANIZATION_NAME
  end

  it 'should retrieve an organization guid' do
    org = @orgs.get_organization_by_name(ORGANIZATION_NAME)
    org.guid.should == @org_guid
  end

  it 'should read the organizations list' do
    readed = @orgs.read_all(@testing_data.user.guid)
    readed.should_not == nil
  end

  it 'should read no spaces (new organizations do not have spaces by default)' do
    spaces = @orgs.read_spaces(@org_guid)
    spaces.should == []
  end

  # the total amount of members
  it 'should receive an amount of members for the current organization' do
    members = @orgs.get_members_count(@org_guid)
    members.should_not == nil
  end

  # reads all user types an retrieves the amount of each
  # there are users set up by default when an organization is created
  it 'should count owners' do
    owners = @orgs.read_owners(@testing_data.config, @org_guid)
    owners.should_not == nil
  end
  it 'should count billing managers' do
    billings = @orgs.read_billings(@testing_data.config, @org_guid)
    billings.should_not == nil
  end
  it 'should count auditors' do
    auditors = @orgs.read_auditors(@testing_data.config, @org_guid)
    auditors.should == [] # there are no default auditors
  end

  # update and delete the organization tests after the previous tests were done
  # last methods are update and delete in order
  it 'should update the organization name' do
    updated = @orgs.update(NEW_ORGANIZATION_NAME, @org_guid)
    updated.should_not == nil
  end

  it 'should delete the organization' do
    deleted = @orgs.delete(@testing_data.config, @org_guid)
    deleted.should_not == nil
  end
end
