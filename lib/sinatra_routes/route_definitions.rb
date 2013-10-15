require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes

    INDEX                     = '/'

    LOGIN                     = "#{INDEX}login"
    SIGNUP                    = "#{INDEX}signup"
    PLEASE_CONFIRM            = "#{INDEX}confirm"
    ACTIVATE_ACCOUNT          = "#{INDEX}activate/:password/:guid/:email"
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
    APP_CREATE_FEEDBACK       = "#{SPACE}/create_app_feedback/:id"
    APP_UPDATE_FEEDBACK       = "#{SPACE}/update_app_feedback/:id"
    SERVICES_CREATE           = "#{SPACE}/create_service/new"
    SPACE_MEMBERS_ADD         = "#{SPACE}/add_user/new"
    ROUTES_CREATE             = "#{SPACE}/add_route/new"
    DOMAINS_MAP_SPACE         = "#{SPACE}/map_domain/new"


    FEEDBACK                  = "/feedback/:id"

    ADMINISTRATION            = "/admin"
    ADMINISTRATION_WEBUI      = "#{ADMINISTRATION}/webui"
    ADMINISTRATION_CONTACT    = "#{ADMINISTRATION}/contact"
    ADMINISTRATION_BILLING    = "#{ADMINISTRATION}/billing"
    ADMINISTRATION_EMAIL      = "#{ADMINISTRATION}/email"
    ADMINISTRATION_REPORTS    = "#{ADMINISTRATION}/reports"
    ADMINISTRATION_TEMPLATES  = "#{ADMINISTRATION}/templates"

  end
end