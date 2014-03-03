require 'uaa'
require 'config'

#this class contains all the functionality that deals with uaa users and cf users
class UsersSetup

  def initialize(config)
    @config         = config
    @uaaApi         = @config[:uaa][:url]
    @client_id      = @config[:uaa][:client_id]
    @client_secret  = @config[:uaa][:client_secret]
    @cf_target      = @config[:cloud_controller_url]
  end

  # login functionality for a user
  def login(email, password)
    user_token = get_user_token(email, password)

    raise 'Authentication error' if defined?(user_token.info['error']) || defined?(user_token.info['error_description'])

    users_obj = Library::Users.new(user_token, @cf_target)
    user_guid = users_obj.get_user_guid
    user_detail = get_details(user_guid)

    is_admin = user_detail['groups'].any? { |group| group['display'] == 'cloud_controller.admin' }

    UserDetails.new(user_token, user_guid, user_detail["name"]["givenname"], user_detail["name"]["familyname"], is_admin)
  end

  # signup functionality for a user
  def signup(email, password, first_name, last_name)

    uaac = get_uaa_client

    # if user already exist in uaa continue with next steps without creating it
    begin
      user_id = uaac.id(:user, email)
      user = uaac.get(:user, user_id)
    rescue
      #  do nothing user doesn't exist in uaa so it will be created next
    end

    unless user
     emails = [email]
      info = {userName: email, password: password, name: {givenName: first_name, familyName: last_name}}
      info[:emails] = emails.respond_to?(:each) ?
          emails.each_with_object([]) { |email, obj| obj.unshift({:value => email}) } :
          [{:value => (emails || name)}]

      user = uaac.add(:user, info)
    end

    if user != nil
      user_id = user['id']
      admin_token = get_admin_token

      raise 'The username already exists' if defined?(admin_token.info['error']) || defined?(admin_token.info['error_description'])

      #the username password should be generated for each user for better security
      user_token = get_user_token(email, $config[:webui][:activation_link_secret])

      raise 'The username already exists' if defined?(user_token.info['error']) || defined?(user_token.info['error_description'])

      UserDetails.new(user_token, user_id, first_name, last_name, false)
    end
  end

  # this method is used for changing the user first name and last name
  def update_user_info(user_guid, given_name, family_name)
    uaac = get_uaa_client
    info = uaac.get(:user, user_guid)
    info['name'] = {givenName: given_name, familyName: family_name}
    uaac.put(:user, info)
  end

  # this method is used for changing the user password
  def change_password(user_id, verified_password, old_password)
    uaac = get_uaa_client
    uaac.change_password(user_id, verified_password, old_password)
  end

  # this method returns the uaa client object
  # (used for connecting to the uaa database)
  def get_uaa_client
    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
    token = token_issuer.client_credentials_grant()

    uaac = CF::UAA::Scim.new(@uaaApi, token.auth_header)

    uaac
  end

  # this method returns a username from a user guid
  def get_username_from_guid(user_guid)
    uaac = get_uaa_client
    uaa_user = uaac.get(:user, user_guid)

    uaa_user['username']
  end

  # returns all users from the uaa
  def uaa_get_users()
    uaac = get_uaa_client

    all_users = uaac.query(:user, {})["resources"].map do |user|
      {
          id: user["id"],
          first_name: user["name"]["givenname"].to_s,
          last_name: user["name"]["familyname"].to_s,
          email: user["username"],
          is_admin: user['groups'].any? { |group| group['display'] == 'cloud_controller.admin' }
      }
    end

    all_users
  end

  # delete a user from a user guid
  def delete_user(user_id)
    uaac = get_uaa_client

    uaac.delete(:user, user_id)
  end

  # a method user for recovering the user password
  def recover_password(user_id, password)
    get_uaa_client.change_password(user_id, password)
  end

  # returns a user guid from a user object
  def uaa_get_user_by_name(username)
    uaac = get_uaa_client
    begin
      user_id = uaac.id(:user, username)
      return user_id
    rescue
      return nil
    end
  end

  # returns the user object from a user guid
  def get_details(user_guid)
    uaac = get_uaa_client
    uaac.get(:user, user_guid)
  end


  # retrieves an admin token
  def get_admin_token
    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
    token = token_issuer.client_credentials_grant()
    CFoundry::AuthToken.from_uaa_token_info(token)
  end

  # retrieves a user token
  def get_user_token(email, password)
    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
    token_obj = token_issuer.owner_password_grant(email, password)
    CFoundry::AuthToken.from_uaa_token_info(token_obj)
  end

  # Data holder for the user details
  class UserDetails
    attr_reader :token, :guid, :first_name, :last_name, :is_admin

    def initialize(token, guid, first_name, last_name, is_admin)
      @token = token
      @guid = guid
      @first_name = first_name
      @last_name = last_name
      @is_admin = is_admin
    end
  end

end