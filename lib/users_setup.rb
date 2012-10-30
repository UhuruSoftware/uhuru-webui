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

    uaac = CF::UAA::UserAccount.new('http://uaa.ccng-dev.net', token.info[:token_type] + ' ' + token.info[:access_token])

    emails = [email]
    uaac.create(email, password, emails, given_name, family_name, nil)

    #user_token = get_user_token(email, password)

    user_token = get_user_token('sre@vmware.com', 'a')

    organizations_Obj = Organizations.new(user_token)

    org_name = email + "'s organization"
    if (organizations_Obj.create(org_name))
      orgs = organizations_Obj.get_organization_by_name(org_name)

      org_guid = orgs[0].guid

      users_obj = Users.new(user_token)
      users_obj.add_user_to_org_with_role(org_guid, email, nil)
    end

    rescue Exception => e
      "#{e.inspect}, #{e.backtrace}"
    
  end
  
  def get_user_token(email, password)

    #to be deleted when all users can create organizations and etc..
    #email = 'sre@vmware.com'
    #password = 'a'

    creds = {}
    creds['username'] = email
    creds['password'] = password

    token_issuer = CF::UAA::TokenIssuer.new(UhuruConfig.uaa_api, "vmc", "")
    token_obj = token_issuer.implicit_grant_with_creds(creds)

    tokinfo = CF::UAA::TokenCoder.decode(token_obj.info[:access_token], nil, nil, false)

    CF::UAA::Config.load(UhuruConfig.uaac_path)
    CF::UAA::Config.context = tokinfo[:email]
    CF::UAA::Config.add_opts(user_id: tokinfo[:user_id])
    CF::UAA::Config.add_opts token


    token_obj.info[:token_type] + ' ' + token_obj.info[:access_token]

    rescue Exception => e
      "#{e.inspect}, #{e.backtrace}"
  end  

end