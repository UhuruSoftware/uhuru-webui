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

  def login(email, password)
    begin
      user_token = get_user_token(email, password)

      begin
        raise 'Authentication error' if defined?(user_token.info['error']) || defined?(user_token.info['error_description'])
      rescue Exception => e
        return e
      end

      users_obj = Library::Users.new(user_token, @cf_target)
      user_guid = users_obj.get_user_guid
      user_detail = get_details(user_guid)

      user = UserDetails.new(user_token, user_guid, user_detail["familyname"], user_detail["givenname"])
      user
    rescue Exception => e
      return e
    end
  end

  def signup(email, password, first_name, last_name)

    begin
      uaac = get_uaa_client
    rescue Exception => e
      return e
    end

    # if user already exist in uaa continue with next steps without creating it
    begin
      user_id = uaac.id(:user, email)
      user = uaac.get(:user, user_id)
    rescue
      #  do nothing user doesn't exist in uaa so it will be created next
    end

    unless user
      begin
        emails = [email]
        info = {userName: email, password: password, name: {givenName: first_name, familyName: last_name}}
        info[:emails] = emails.respond_to?(:each) ?
            emails.each_with_object([]) { |email, o| o.unshift({:value => email}) } :
            [{:value => (emails || name)}]

        user = uaac.add(:user, info)
      rescue Exception => e
        return e
      end
    end

    if (user != nil)
      user_id = user['id']
      admin_token = get_admin_token

      begin
        raise 'The username already exists' if defined?(admin_token.info['error']) || defined?(admin_token.info['error_description'])
      rescue Exception => e
        return e
      end

      #the username password shoud be generated for each user for better security
      user_token = get_user_token(email, $config[:webui][:activation_link_secret])

      begin
        raise 'The username already exists' if defined?(user_token.info['error']) || defined?(user_token.info['error_description'])
      rescue Exception => e
        return e
      end

      user = UserDetails.new(user_token, user_id, first_name, last_name)
      user
    end
  end

  def update_user_info(user_guid, given_name, family_name)
    user_attributes = {name: {givenName: given_name, familyName: family_name}}
    uaac = get_uaa_client
    uaa_user = uaac.get(:user, user_guid)
    uaac.update(user_guid, uaa_user.merge(user_attributes))

  rescue Exception => e
    return e
  end

  def change_password(user_id, verified_password, old_password)
    uaac = get_uaa_client
    uaac.change_password(user_id, verified_password, old_password)

  rescue Exception => e
    return e
  end

  def get_uaa_client
    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
    token = token_issuer.client_credentials_grant()

    uaac = CF::UAA::Scim.new(@uaaApi, token.auth_header)

    uaac
  end

  def get_username_from_guid(user_guid)
    uaac = get_uaa_client
    uaa_user = uaac.get(:user, user_guid)

    uaa_user['username']
  end

  # todo: stefi: consider not using this method or at least once per server instance. may have scalability problems
  # returns an array with all usernames in uaa
  # added the possibility to filter usernames with 'contains' the string received as a parameter
  def uaa_get_usernames(filter_by = String.new)
    uaac = get_uaa_client
    users = uaac.query(:user, {:attributes => 'username', :filter => 'userName co "' + filter_by + '"' })
    users['resources'].collect { |u| u['username']}
  end

  def uaa_get_user_by_name(username)
    uaac = get_uaa_client
    begin
      user_id = uaac.id(:user, username)
      return user_id
    rescue
      return nil
    end
  end

  def get_details(user_guid)
    uaac = get_uaa_client
    return uaac.get(:user, user_guid)
  rescue Exception => e
    raise "#{e.inspect}"
  end


  def get_admin_token
    begin
      token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
      token = token_issuer.client_credentials_grant()
      CFoundry::AuthToken.from_uaa_token_info(token)
    rescue Exception => e
      return e
    end
  end

  def get_user_token(email, password)
    begin
      token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
      token_obj = token_issuer.owner_password_grant(email, password)
      CFoundry::AuthToken.from_uaa_token_info(token_obj)
    rescue Exception => e
      return e
    end
  end

  class UserDetails
    attr_reader :token, :guid, :first_name, :last_name

    def initialize(token, guid, first_name, last_name)
      @token = token
      @guid = guid
      @first_name = first_name
      @last_name = last_name
    end
  end

end