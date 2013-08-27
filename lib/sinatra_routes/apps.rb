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

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          user = UsersSetup.new($config)
          route = Library::Routes.new(session[:token], $cf_target)
          all_space_users = user.uaa_get_usernames

          space.set_current_space(params[:space_guid])
          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          routes_list = route.read_routes(params[:space_guid])

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])

          collections = app.read_collections


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
                      :error_message => error_message,
                      :app => params[:app],
                      :error_message => error_message
                  }
              }
        end

        app.get APP_CREATE do

          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          user = UsersSetup.new($config)
          route = Library::Routes.new(session[:token], $cf_target)
          all_space_users = user.uaa_get_usernames

          space.set_current_space(params[:space_guid])
          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          routes_list = route.read_routes(params[:space_guid])

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])

          collections = app.read_collections

          erb :'user_pages/space',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :space_name => space.get_name(params[:space_guid]),
                      :current_organization => params[:org_guid],
                      :current_space => params[:space_guid],
                      :current_tab => params[:tab],
                      :apps => collections,
                      :all_space_users => all_space_users,
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :routes_list => routes_list,
                      :error_message => '',
                      :include_erb => :'user_pages/modals/apps_create'
                  }
              }
        end

        app.get '/app_logo/:app_id' do
          #apps = TemplateApps.read_apps
          #app_id = params[:app_id]
          #content_type 'image/png'
          #send_file apps[app_id]['logo']
          redirect '/organizations'
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
          delete = Applications.new(session[:token], $cf_target).delete(params[:appGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=delete_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/startApp' do
          start = Applications.new(session[:token], $cf_target).start_app(params[:appName])

          if start == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=start_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/stopApp' do
          stop = Applications.new(session[:token], $cf_target).stop_app(params[:appName])

          if stop == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=stop_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/updateApp' do
          update = Applications.new(session[:token], $cf_target).update(params[:appName], params[:appInstances].to_i, params[:appMemory].to_i)

          if update == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=update_app'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end




        app.post '/bindServices' do
          bind = Applications.new(session[:token], $cf_target).bind_app_services(params[:appName], params[:serviceName])

          if bind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=bind_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/bindUri' do
          domain_guid = Library::Domains.new(session[:token], $cf_target).get_organizations_domain_guid(params[:current_organization])

          bind = routes.create(params[:appName], params[:current_space], domain_guid, params[:uriName])

          if bind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=bind_uri'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/unbindServices' do
          unbind = Applications.new(session[:token], $cf_target).unbind_app_services(params[:appName], params[:serviceName])

          if unbind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=unbind_service'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/unbindUri' do
          unbind = Applications.new(session[:token], $cf_target).unbind_app_url(params[:appName], $config[:cloud_controller_url], params[:uriName])

          if unbind == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + '?error=unbind_uri'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

      end
    end
  end
end