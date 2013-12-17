require 'spec_helper.rb'

describe 'Main tests for users' do
  before(:each) do
    @testing_data = Mocking::Initializing.new
    @testing_data.clean_previous_tests

    # prepare a new organization and space for testings
    @users = Library::Users.new(@testing_data.user.token, @testing_data.target)
    @org_guid = Library::Organizations.new(@testing_data.user.token, @testing_data.target).create(@testing_data.config, ORGANIZATION_NAME, @testing_data.user.guid)
    @space_guid = Library::Spaces.new(@testing_data.user.token, @testing_data.target).create(@org_guid, SPACE_NAME)

    setup = UsersSetup.new(@testing_data.config)
    @user_guid = setup.signup(TEST_USER, TEST_USER_PASSWORD, TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME).guid
  end

  it 'should exist after it was created' do
    #@users.user_exists(@user_guid).should == true
    #get_user_from_ccng(user_guid)
  end

  it 'should add the test user tot the organization' do
    @users.add_user_to_org_with_role(@org_guid, @user_guid, ['owner']).should == true
  end

  it 'should add the test user tot the space' do
    @users.add_user_with_role_to_space(@space_guid, @user_guid, ['owner']).should == true
  end

  it 'should check the user org roles' do
    @users.check_user_org_roles(@org_guid, @user_guid, ['owner']).should_not == []
  end

  it 'should check if the user has any org roles' do
    @users.any_org_roles?(@testing_data.config, @org_guid, TEST_USER)
  end

  it 'should remove the user from the organization' do
    @users.remove_user_with_role_from_org(@org_guid, @user_guid, 'owner').should == true
  end

  it 'should remove the user from the space' do
    @users.remove_user_with_role_from_space(@space_guid, @user_guid, 'owner').should == true
  end

end