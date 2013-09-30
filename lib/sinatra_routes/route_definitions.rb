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


    SPACE                     = "#{ORGANIZATIONS}/:org_guid/:spaces/:space_guid/:tab"
    APP                       = "#{ORGANIZATIONS}/:org_guid/:spaces/:space_guid/:tab/:app_name"

    APP_CREATE                = "#{SPACE}/create_app/new"
    SERVICES_CREATE           = "#{SPACE}/create_service/new"
    SPACE_MEMBERS_ADD         = "#{SPACE}/add_user/new"
    ROUTES_CREATE             = "#{SPACE}/add_route/new"
    DOMAINS_MAP_SPACE         = "#{SPACE}/map_domain/new"

  end
end