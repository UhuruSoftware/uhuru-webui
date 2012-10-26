$:.unshift(File.join(File.dirname(__FILE__)))

require 'uaa'
require 'uhuru_config'
require 'lib/users'
require 'lib/organizations'

class Users_Setup

  def add_user(email, password, given_name, family_name)

    token_issuer = CF::UAA::TokenIssuer.new(UhuruConfig.uaa_api, UhuruConfig.client_id, UhuruConfig.client_secret)
    token = token_issuer.client_credentials_grant()

    uaac = CF::UAA::UserAccount.new('http://uaa.ccng-dev.net', token.info[:token_type] + ' ' + token.info[:access_token])

    emails = [email]
    uaac.create(email, password, emails, given_name, family_name, nil)

    #user_token = get_user_token(email, password)

    user_token = get_user_token('sre@vmware.com', 'a')

    organizations_Obj = Organizations.new(user_token)

    org_name = email + "'s organization'"
    if (organizations_Obj.create(org_name))
      orgs = organizations_Obj.read_all

      org_guid = orgs[0].guid

      users_obj = Users.new(user_token)
      users_obj.add_user_to_org_with_role(org_guid, email, nil)
    end

    rescue Exception => e
      "#{e.inspect}, #{e.backtrace}"
    
  end
  
  def get_user_token(email, password)

    #to be deleted when all users can create organizations and etc..
    email = 'sre@vmware.com'
    password = 'a'

    creds = {}
    creds['username'] = email
    creds['password'] = password

    token_issuer = CF::UAA::TokenIssuer.new(UhuruConfig.uaa_api, "vmc", "")
    token_obj = token_issuer.implicit_grant_with_creds(creds)
    token_obj.info[:token_type] + ' ' + token_obj.info[:access_token]

    rescue Exception => e
      "#{e.inspect}, #{e.backtrace}"
  end  

end