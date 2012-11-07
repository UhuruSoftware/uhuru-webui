require 'uaa'
require 'config'

class UsersSetup

  def initialize(config)
    @config = config
    @uaaApi = @config[:uaa][:uaa_api]
    @client_secret = @config[:cloudfoundry][:client_secret]
    @client_id = @config[:cloudfoundry][:client_id]
    @cf_target = @config[:cloudfoundry][:cloud_controller_api]
    @cf_admin = @config[:cloudfoundry][:cloud_controller_admin]
    @cf_pass = @config[:cloudfoundry][:cloud_controller_pass]
  end

  def login(email, password)
    user_token = get_user_token(email, password)

    users_obj = Users.new(user_token, @cf_target)
    user_guid = users_obj.get_user_guid

    user_detail = get_user_details(user_guid)

    user = UserDetails.new(user_token, user_guid, user_detail[:first_name], user_detail[:last_name])
    user
  rescue Exception => e
    raise "#{e.inspect}"
  end

  def signup(email, password, first_name, last_name)
    new_user = add_user(email, password, first_name, last_name)

    user = UserDetails.new(new_user[:user_token], new_user[:user_id], first_name, last_name)
    user
  rescue Exception => e
    raise "#{e.inspect}"
  end

  private

  def add_user(email, password, given_name, family_name)

    uaac = get_uaa_client

    emails = [email]

    info = {userName: email, password: password, name: {givenName: given_name, familyName: family_name}}
    info[:emails] = emails.respond_to?(:each) ?
        emails.each_with_object([]) { |email, o| o.unshift({:value => email}) } :
        [{:value => (emails || name)}]

    user = uaac.add(info)
    if (user != nil)
      user_id = user[:id]

      #user_token = get_user_token(email, password)

      user_token = get_user_token(@cf_admin, @cf_pass)

      organizations_Obj = Organizations.new(user_token, @cf_target)
      org_name = email + "'s organization"
      org_guid = organizations_Obj.create(org_name)

      users_obj = Users.new(user_token, @cf_target)
      cfuser = users_obj.add_user_to_org_with_role(org_guid, user_id, ['owner', 'billing'])

       {:user_id => user_id, :user_token => user_token}
    end

  rescue Exception => e
    uaac.delete_by_name(email) if user != nil
    organizations_Obj.delete(org_guid) if org_guid != nil
    users_obj.delete(user_id) if cfuser

    raise "#{e.inspect}"
  end

  def get_user_token(email, password)
    creds = {}
    creds['username'] = email
    creds['password'] = password

    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, "vmc", "")
    token_obj = token_issuer.implicit_grant_with_creds(creds)
    token_user = token_obj.info[:token_type] + ' ' + token_obj.info[:access_token]

    token_user
  rescue Exception => e
    raise "#{e.inspect}"
  end

  def get_user_details(user_guid)
    uaac = get_uaa_client

    uaa_user = uaac.get(user_guid)

    user_details = {:first_name => uaa_user[:name][:givenName], :last_name => uaa_user[:name][:familyName]}

    user_details
  rescue Exception => e
    raise "#{e.inspect}"
  end

  def get_uaa_client
    token_issuer = CF::UAA::TokenIssuer.new(@uaaApi, @client_id, @client_secret)
    token = token_issuer.client_credentials_grant()

    uaac = CF::UAA::UserAccount.new(@uaaApi, token.info[:token_type] + ' ' + token.info[:access_token])

    uaac
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