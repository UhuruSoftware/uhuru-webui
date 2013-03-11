require 'sinatra/base'


#Service plan should not be hardcoded

module Uhuru::Webui
  module SinatraRoutes
    module Services
      def self.registered(app)

        app.get SERVICES_CREATE do

          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          readapps_Obj = TemplateApps.new
          users_setup_Obj = UsersSetup.new($config)
          all_space_users = users_setup_Obj.uaa_get_usernames

          #session[:space_name] = spaces_Obj.get_name(@this_guid)

          spaces_Obj.set_current_space(params[:space_guid])
          apps_list = spaces_Obj.read_apps(params[:space_guid])
          services_list = spaces_Obj.read_service_instances(params[:space_guid])

          owners_list = spaces_Obj.read_owners($config, params[:space_guid])
          developers_list = spaces_Obj.read_developers($config, params[:space_guid])
          auditors_list = spaces_Obj.read_auditors($config, params[:space_guid])

          collections = readapps_Obj.read_collections

          if params[:error] == 'create_service'
            error_message = $errors['create_service_error']
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
                      :users_count => owners_list.count + developers_list.count + auditors_list.count,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :apps_count => apps_list.count,
                      :services_count => services_list.count,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/services_create'
                  }
              }
        end


        app.post '/createService' do
          @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = ServiceInstances.new(session[:token], $cf_target)
          create = spaces_Obj.create_service_instance(params[:serviceName], params[:current_space], @plan)

          if create == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/create_service" + '?error=create_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/deleteService' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          applications_Obj = Applications.new(session[:token], $cf_target)
          services_Obj = ServiceInstances.new(session[:token], $cf_target)
          delete = services_Obj.delete(params[:serviceGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}" + '?error=delete_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end