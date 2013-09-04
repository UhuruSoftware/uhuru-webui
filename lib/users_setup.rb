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
      if user_token == 'user_token_error'
        return 'error'
      end

      users_obj = Library::Users.new(user_token, @cf_target)
      user_guid = users_obj.get_user_guid
      user_detail = get_details(user_guid)

      user = UserDetails.new(user_token, user_guid, user_detail["familyname"], user_detail["givenname"])
      user
    rescue Exception => e
      puts e
      return 'error'
    end
  end

  def signup(email, password, first_name, last_name)

    begin
      uaac = get_uaa_client
    rescue Exception => e
      puts e
      return 'error'
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
        puts e
        return 'user exists'
      end
    end

    if (user != nil)
      user_id = user['id']
      admin_token = get_admin_token

      if admin_token != 'user_token_error'
        #admin_token = CFoundry::AuthToken.new(admin_token)
        users_obj = Library::Users.new(admin_token, @cf_target)
        organizations_Obj = Library::Organizations.new(admin_token, @cf_target)
        org_name = email + "'s organization"
        org = organizations_Obj.get_organization_by_name(org_name)
      else
        return 'org create error'
      end

      unless users_obj.user_exists(user_id)
        begin
          orgs = organizations_Obj.read_orgs_by_user(user_id)

          if orgs == nil && org == nil
            # when user has no default org and no other org, create default org
            org_guid = organizations_Obj.create(@config, org_name, user_id)
          elsif orgs != nil
            # this should check if for any of the orgs, the user is owner and billing, if not should create the default org
            correct_roles = true

            orgs.foreach do |org|
              correct_roles = correct_roles && users_obj.check_user_org_roles(org.guid, user_id, ['owner', 'billing'])
            end

            if correct_roles == false
              organizations_Obj.create(@config, org_name, user_id)
            end

          elsif org != nil
            # when user has default org, but user and roles are not in db

            users_obj.add_user_to_org_with_role(org.guid, user_id, ['owner', 'billing'])
          end
        rescue Exception => e
          puts e
          return 'org create error'
        end
      else
        begin
          #this part checks if the default org has the right roles - when user is added to default org, but could not add roles
          if org != nil
            users_obj.add_user_to_org_with_role(org.guid, user_id, ['owner', 'billing'])
          end
        rescue Exception => e
          puts e
          return 'org create error'
        end
      end

      user_token = get_user_token(email, password)

      if user_token == 'user_token_error'
        return 'user exists'
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
    puts e
    puts 'update user method error'
    return 'error'
  end

  def change_password(user_id, verified_password, old_password)
    uaac = get_uaa_client
    uaac.change_password(user_id, verified_password, old_password)

  rescue Exception => e
    puts e
    puts 'update password method error'
    return 'error'
  end

  def get_admin_token
    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
    token = token_issuer.client_credentials_grant()
    CFoundry::AuthToken.from_uaa_token_info(token)
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

  private

  def get_user_token(email, password)

    begin
      token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
      # token_obj = token_issuer.implicit_grant_with_creds(username: email, password: password)
      token_obj = token_issuer.owner_password_grant(email, password)

      CFoundry::AuthToken.from_uaa_token_info(token_obj)
    rescue Exception => e
      puts e
      puts 'get_user_token method error'
      return 'user_token_error'
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