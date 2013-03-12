require 'sinatra/base'


#
#    TODO:: There are some variables in this code that should not be hardcoded
#


module Uhuru::Webui
  module SinatraRoutes
    module Apps
      def self.registered(app)

        app.get APP do

          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          readapps_Obj = TemplateApps.new
          users_setup_Obj = UsersSetup.new($config)
          all_space_users = users_setup_Obj.uaa_get_usernames

          spaces_Obj.set_current_space(params[:space_guid])
          apps_list = spaces_Obj.read_apps(params[:space_guid])
          services_list = spaces_Obj.read_service_instances(params[:space_guid])

          owners_list = spaces_Obj.read_owners($config, params[:space_guid])
          developers_list = spaces_Obj.read_developers($config, params[:space_guid])
          auditors_list = spaces_Obj.read_auditors($config, params[:space_guid])

          collections = readapps_Obj.read_collections



          if params[:error] == 'delete_app'
            error_message = $errors['delete_app_error']
          elsif params[:error] == 'start_app'
            error_message = $errors['start_app_error']
          elsif params[:error] == 'stop_app'
            error_message = $errors['stop_app_error']
          elsif params[:error] == 'update_app'
            error_message = $errors['update_app_error']
          elsif params[:error] == 'bind_service'
            error_message = $errors['bind_service_error']
          elsif params[:error] == 'bind_uri'
            error_message = $errors['bind_uri_error']
          elsif params[:error] == 'unbind_service'
            error_message = $errors['unbind_service_error']
          elsif params[:error] == 'unbind_uri'
            error_message = $errors['unbind_uri_error']
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
                      :app => params[:app],
                      :error_message => error_message
                  }
              }
        end

        app.get APP_CREATE do

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
                      :include_erb => :'user_pages/modals/apps_create'
                  }
              }
        end


        #app.post '/createApp' do
        #  #@name =
        #  #@runtime =
        #  #@framework =
        #  instance = 1
        #  #@memory =
        #  #@path =
        #  #@domain =
        #  #@plan =
        #
        #  organizations_Obj = Organizations.new(session[:token], $cf_target)
        #  spaces_Obj = Spaces.new(session[:token], $cf_target)
        #  apps_obj = Applications.new(session[:token], $cf_target)
        #  apps_obj.create(session[:currentOrganization], session[:currentSpace], params[:appName], params[:appRuntime], params[:appFramework], instance, params[:appMemory].to_i, params[:appDomain], params[:appPath], params[:appPlan])
        #
        #  #redirect "/space" + session[:currentSpace]
        #
        #end

        app.post '/deleteApp' do
          applications_Obj = Applications.new(session[:token], $cf_target)
          delete = applications_Obj.delete(params[:appGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}" + '?error=delete_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/startApp' do
          apps_obj = Applications.new(session[:token], $cf_target)
          start = apps_obj.start_app(params[:appName])

          if start == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=start_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/stopApp' do
          apps_obj = Applications.new(session[:token], $cf_target)
          stop = apps_obj.stop_app(params[:appName])

          if stop == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=stop_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/updateApp' do
          apps_obj = Applications.new(session[:token], $cf_target)
          update = apps_obj.update(params[:appName], params[:appInstances].to_i, params[:appMemory].to_i)

          if update == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=update_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end








        app.post '/bindServices' do
          apps = Applications.new(session[:token], $cf_target)
          bind = apps.bind_app_services(params[:appName], params[:serviceName])

          if bind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=bind_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/bindUri' do
          domain_obj = Library::Domains.new(session[:token], $cf_target)
          domain_guid = domain_obj.get_organizations_domain_guid(params[:current_organization])

          routes = Library::Routes.new(session[:token], $cf_target)
          bind = routes.create(params[:appName], params[:current_space], domain_guid, params[:uriName])

          if bind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=bind_uri'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/unbindServices' do
          apps = Applications.new(session[:token], $cf_target)
          unbind = apps.unbind_app_services(params[:appName], params[:serviceName])

          if unbind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=unbind_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/unbindUri' do
          apps = Applications.new(session[:token], $cf_target)
          unbind = apps.unbind_app_url(params[:appName], $config[:cloudfoundry][:cloud_controller_api], params[:uriName])

          if unbind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=unbind_uri'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

      end
    end
  end
end