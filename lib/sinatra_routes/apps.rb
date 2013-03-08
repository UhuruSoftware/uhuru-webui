require 'sinatra/base'


#
#    TODO:: There are some variables in this code that should not be hardcoded
#


module Uhuru::Webui
  module SinatraRoutes
    module Apps
      def self.registered(app)

        app.get APPS_CREATE do

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

        app.get APP_DETAILS do
          puts "app details"
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
                      :include_erb => :'user_pages/modals/app_details'
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
          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)
          applications_Obj = Applications.new(session[:token], $cf_target)

          applications_Obj.delete(params[:appGuid])
          redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}"
        end



        app.post '/startApp' do

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.start_app(params[:appName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/stopApp' do

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.stop_app(params[:appName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/updateApp' do

          #@name =
          #@memory =
          #@instances =

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.update(params[:appName], params[:appInstances], params[:appMemory])

          #redirect "/spaces" + session[:currentSpace]

        end

        app.post '/bindServices' do

          apps = Applications.new(session[:token], $cf_target)
          apps.bind_app_services(params[:appName], params[:serviceName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/unbindServices' do

          apps = Applications.new(session[:token], $cf_target)
          apps.unbind_app_services(params[:appName], params[:serviceName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/bindUri' do

          @domain_name = "api3.ccng-dev.net"

          apps = Applications.new(session[:token], $cf_target)
          apps.bind_app_url(params[:appName], session[:currentOrganization], @domain_name, params[:uriName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/unbindUri' do

          @domain_name = "http://api3.ccng-dev.net"

          apps = Applications.new(session[:token], $cf_target)
          apps.unbind_app_url(params[:appName], @domain_name, params[:uriName])

          #redirect "/space" + session[:currentSpace]

        end


      end
    end
  end
end