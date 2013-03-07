require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Users
      def self.registered(app)

        app.get SPACE_MEMBERS_ADD do

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
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end




        app.post '/deleteUser' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          users_Obj = Library::Users.new(session[:token], $cf_target)
          users_Obj.remove_user_with_role_from_org(params[:current_organization], params[:thisUser], params[:thisUserRole])

          if params[:current_space] != nil && params[:current_space] != ""
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_space]}/#{params[:current_tab]}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end