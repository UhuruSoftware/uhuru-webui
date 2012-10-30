$:.unshift(File.join(File.dirname(__FILE__)))

require 'uaa'
require 'uhuru_config'
require 'lib/users'
require 'lib/organizations'

class UsersSetup

  def initialize
    UhuruConfig.load
  end

  def add_user(email, password, given_name, family_name)

    token_issuer = CF::UAA::TokenIssuer.new(UhuruConfig.uaa_api, UhuruConfig.client_id, UhuruConfig.client_secret)
    token = token_issuer.client_credentials_grant()

    uaac = CF::UAA::UserAccount.new(UhuruConfig.uaa_api, token.info[:token_type] + ' ' + token.info[:access_token])

    emails = [email]

    info = {userName: email, password: password, name: {givenName: given_name, familyName: family_name}}
    info[:emails] = emails.respond_to?(:each) ?
        emails.each_with_object([]) { |email, o| o.unshift({:value => email}) } :
        [{:value => (emails || name)}]

    user = uaac.add(info)
    user_id = user[:id]

    #user_token = get_user_token(email, password)

    user_token = get_user_token('sre@vmware.com', 'a')

    organizations_Obj = Organizations.new(user_token)

    org_name = email + "'s organization"
    org_guid = organizations_Obj.create(org_name)

    users_obj = Users.new(user_token)
    users_obj.add_user_to_org_with_role(org_guid, user_id, ['owner', 'manager'])

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"

  end

  def get_user_token(email, password)
    creds = {}
    creds['username'] = email
    creds['password'] = password

    token_issuer = CF::UAA::TokenIssuer.new(UhuruConfig.uaa_api, "vmc", "")
    token_obj = token_issuer.implicit_grant_with_creds(creds)

    puts token_obj.info[:token_type] + ' ' + token_obj.info[:access_token]

    token_obj.info[:token_type] + ' ' + token_obj.info[:access_token]

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

end