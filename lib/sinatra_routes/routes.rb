require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Routes
      def self.registered(app)

        app.get ROUTES_CREATE do

          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          user = UsersSetup.new($config)
          route = Library::Routes.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_space_users = user.uaa_get_usernames

          space.set_current_space(params[:space_guid])
          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          routes_list = route.read_routes(params[:space_guid])
          domains_list = domain.read_domains()

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])

          collections = app.read_collections
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/space',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :space_name => space.get_name(params[:space_guid]),
                      :current_organization => params[:org_guid],
                      :current_space => params[:space_guid],
                      :current_tab => params[:tab],
                      :collections => collections,
                      :all_space_users => all_space_users,
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :routes_list => routes_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/routes_create'
                  }
              }
        end


        app.post '/createRoute' do
          create = Library::Routes.new(session[:token], $cf_target).create(params[:appName], params[:current_space], params[:domain_guid], params[:host])

          if defined?(create.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_route/new" + "?error=#{create.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/deleteRoute' do
          delete = Library::Routes.new(session[:token], $cf_target).delete(params[:routeGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end