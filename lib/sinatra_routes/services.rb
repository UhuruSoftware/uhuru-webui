require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Services
      def self.registered(app)

        app.get SERVICES_CREATE do
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
          domains_list = domain.read_domains(params[:org_guid])

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])

          collections = app.read_collections

          if params[:error] == 'create_service'
            if params[:message] == 'name_size'
              error_message = $errors['service_error_name_size']
            else
              error_message = $errors['create_service_error']
            end
          else
            error_message = ''
          end

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
                      :include_erb => :'user_pages/modals/services_create'
                  }
              }
        end

        app.post '/createService' do
          #plan = "ff33164f-7d84-4392-b467-ed6c3eac0463" # wardenized: 3ae1cc4f-0c55-4d32-8e75-2cc1ec5ac011   ||  free: ff33164f-7d84-4392-b467-ed6c3eac0463

          if params[:serviceName].size >= 4
            create = ServiceInstances.new(session[:token], $cf_target).create_service_instance(params[:serviceName], params[:current_space], params[:service_plan], params[:service_type])
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + '?error=create_service&message=name_size'
          end

          if create == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + '?error=create_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/deleteService' do
          delete = ServiceInstances.new(session[:token], $cf_target).delete(params[:serviceGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=delete_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end