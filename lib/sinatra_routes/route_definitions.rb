require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes

    INDEX                     = '/'

    LOGIN                     = "#{INDEX}login"
    SIGNUP                    = "#{INDEX}signup"
    PLEASE_CONFIRM            = "#{INDEX}confirm"
    ACTIVATE_ACCOUNT          = "#{INDEX}activate/:password/:email"
    ACTIVE                    = "#{INDEX}active"
    LOGOUT                    = "#{INDEX}logout"


    ACCOUNT                   = "#{INDEX}account"
    INFO_PAGE                 = "#{INDEX}info"

    ORGANIZATIONS             = "#{INDEX}organizations"
    ORGANIZATIONS_CREATE      = "#{ORGANIZATIONS}/create"

    ORGANIZATION              = "#{ORGANIZATIONS}/:org_id"

    ORGANIZATION_MEMBERS      = "#{ORGANIZATION}/members"
    ORGANIZATION_MEMBERS_ADD  = "#{ORGANIZATION_MEMBERS}/add"

    DOMAINS                   = "#{ORGANIZATION}/domains"
    DOMAINS_CREATE            = "#{DOMAINS}/create"

    SPACES                    = "#{ORGANIZATION}/spaces"
    SPACES_CREATE             = "#{SPACES}/create"

    SPACE                     = "#{SPACES}/:space_id"

    APPS                      = "#{SPACE}/apps"
    APPS_CREATE               = "#{APPS}/create"
    APPS_CREATE_CONFIGURE     = "#{APPS_CREATE}/configure"

    APP                       = "#{APPS}/:app_id"
    APP_BIND_SERVICE          = "#{APP}/bind_service"
    APP_MAP_URI               = "#{APP}/map_uri"


    SERVICES                  = "#{SPACE}/services"
    SERVICES_CREATE           = "#{SERVICES}/create"

    SPACE_MEMBERS             = "#{SPACE}/members"
    SPACE_MEMBERS_ADD         = "#{SPACE_MEMBERS}/add"

    ROUTES                    = "#{SPACE}/routes"
    ROUTES_CREATE             = "#{ROUTES}/create"
  end
end
