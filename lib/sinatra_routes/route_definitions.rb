require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes

    INDEX                     = '/'

    LOGIN                     = "#{INDEX}login"
    SIGNUP                    = "#{INDEX}signup"
    PLEASE_CONFIRM            = "#{INDEX}confirm"
    ACTIVATE_ACCOUNT          = "#{INDEX}activate/:password/:guid"
    ACTIVE                    = "#{INDEX}active"
    LOGOUT                    = "#{INDEX}logout"


    ACCOUNT                   = "#{INDEX}account"
    INFO_PAGE                 = "#{INDEX}info"

    ORGANIZATIONS             = "#{INDEX}organizations"
    ORGANIZATIONS_CREATE      = "#{ORGANIZATIONS}/create_organization"


    ORGANIZATION              = "#{ORGANIZATIONS}/:org_guid/:tab"
    SPACES_CREATE             = "#{ORGANIZATION}/create_space"
    ORGANIZATION_MEMBERS_ADD  = "#{ORGANIZATION}/add_user"
    DOMAINS_CREATE            = "#{ORGANIZATION}/add_domains"


    SPACE                     = "#{ORGANIZATIONS}/:org_guid/:space_guid/:tab"
    APPS_CREATE               = "#{SPACE}/create_app"
    APP_DETAILS               = "#{SPACE}/app_details"
    APPS_CREATE_CONFIGURE     = "#{APPS_CREATE}/configure_app"

    APP                       = "#{SPACE}/app_id"


    SERVICES_CREATE           = "#{SPACE}/create_service"
    SPACE_MEMBERS_ADD         = "#{SPACE}/add_user"
    ROUTES_CREATE             = "#{SPACE}/create_routes"

  end
end