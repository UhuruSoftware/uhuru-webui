require 'spec_helper.rb'

describe 'Main tests for users domains' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    # prepare a new organization and space for testings
    @domains = Library::Domains.new(@testing_data.user.token, @testing_data.target)
    @org_guid = Library::Organizations.new(@testing_data.user.token, @testing_data.target).create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
    @space_guid = Library::Spaces.new(@testing_data.user.token, @testing_data.target).create(@org_guid, SPACE_NAME)

    #create domain
    @domains.create(DOMAIN_NAME, @org_guid, true, @space_guid) # the domain wildcard is boolean

    #get the guid from the new domain
    organization = Library::Organizations.new(@testing_data.user.token, @testing_data.target).get_organization_by_name(ORGANIZATION_NAME)
    @domain_guid = organization.domains.find{|domain| domain.name == DOMAIN_NAME}.guid
  end

  it 'should test create a domain' do
    organization = Library::Organizations.new(@testing_data.user.token, @testing_data.target).get_organization_by_name(ORGANIZATION_NAME)
    organization.domains.find{|domain| domain.name == DOMAIN_NAME}.should_not == nil
  end

  it 'should read the domains in the organization' do
    domains = @domains.read_domains(@org_guid)
    domains.should_not == []
  end

  it 'should read the domains in the space' do
    domains = @domains.read_domains(@org_guid, @space_guid)
    domains.should_not == []
  end

  #it 'should retrieve the organization guid of the current domain' do
  #  @domains.get_organizations_domain_guid(@org_guid)
  #end

  it 'should unmap the domain from the space' do
    @domains.unmap_domain(@domain_guid, nil, @space_guid).should == true
  end

  it 'should unmap the domain from the organization' do
    @domains.unmap_domain(@domain_guid, @org_guid).should == nil # this method is not user, if the domain is no longer needed inside the org, it is deleted instead
  end

  it 'should delete the domain permanently' do
    @domains.delete(@domain_guid).should == true
  end
end
