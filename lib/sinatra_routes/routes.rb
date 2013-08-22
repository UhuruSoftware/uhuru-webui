require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Routes
      def self.registered(app)

        app.get ROUTES_CREATE do

          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          readapps_Obj = TemplateApps.new
          users_setup_Obj = UsersSetup.new($config)
          routes_Obj = Library::Routes.new(session[:token], $cf_target)
          domains_Obj = Library::Domains.new(session[:token], $cf_target)
          all_space_users = users_setup_Obj.uaa_get_usernames

          #session[:space_name] = spaces_Obj.get_name(@this_guid)

          spaces_Obj.set_current_space(params[:space_guid])
          apps_list = spaces_Obj.read_apps(params[:space_guid])
          services_list = spaces_Obj.read_service_instances(params[:space_guid])
          routes_list = routes_Obj.read_routes(params[:space_guid])
          # instanced domains_list variable to avoid repetition in other modals
          @domains_list = domains_Obj.read_domains()

          owners_list = spaces_Obj.read_owners($config, params[:space_guid])
          developers_list = spaces_Obj.read_developers($config, params[:space_guid])
          auditors_list = spaces_Obj.read_auditors($config, params[:space_guid])

          collections = readapps_Obj.read_collections

          if params[:error] == 'create_route'
            error_message = $errors['create_route_error']
          elsif params[:error] == 'delete_route'
            error_message = $errors['delete_route_error']
          else
            error_message = ''
          end

          erb :'user_pages/space',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => organizations_Obj.get_name(params[:org_guid]),
                      :space_name => spaces_Obj.get_name(params[:space_guid]),
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
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/routes_create'
                  }
              }
        end



        app.post '/createRoute' do
          domains_Obj = Library::Domains.new(session[:token], $cf_target)
          routes_Obj = Library::Routes.new(session[:token], $cf_target)
          create = routes_Obj.create(params[:appName], params[:current_space], params[:domain_guid])

          if create == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_route/new" + '?error=create_route'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/deleteRoute' do
          routes_Obj = Library::Routes.new(session[:token], $cf_target)
          delete = routes_Obj.delete(params[:routeAppName], true, params[:routeGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=delete_route'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end