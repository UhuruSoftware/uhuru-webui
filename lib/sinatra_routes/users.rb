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
          routes_Obj = Library::Routes.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_space_users = users_setup_Obj.uaa_get_usernames

          #session[:space_name] = spaces_Obj.get_name(@this_guid)

          spaces_Obj.set_current_space(params[:space_guid])
          apps_list = spaces_Obj.read_apps(params[:space_guid])
          services_list = spaces_Obj.read_service_instances(params[:space_guid])
          routes_list = routes_Obj.read_routes(params[:space_guid])
          domains_list = domain.read_domains(params[:org_guid], params[:space_guid])

          owners_list = spaces_Obj.read_owners($config, params[:space_guid])
          developers_list = spaces_Obj.read_developers($config, params[:space_guid])
          auditors_list = spaces_Obj.read_auditors($config, params[:space_guid])

          collections = readapps_Obj.read_collections

          if params[:error] == 'add_user'
            error_message = $errors['add_user_error']
          elsif params[:error] == 'delete_user'
            error_message = $errors['delete_user_error']
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
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end




        app.post '/addUser' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          users_Obj = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            add_user = users_Obj.invite_user_with_role_to_org($config, params[:userEmail], params[:current_organization], params[:userType])

            if add_user == 'error'
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + '?error=add_user'
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            end
          else
            add_user = users_Obj.invite_user_with_role_to_space($config, params[:userEmail], params[:current_space], params[:userType])

            if add_user == 'error'
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + '?error=add_user'
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            end
          end
        end

        app.post '/deleteUser' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          users_Obj = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            delete_user = users_Obj.remove_user_with_role_from_org(params[:current_organization], params[:thisUser], params[:thisUserRole])

            if delete_user == 'error'
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + '?error=delete_user'
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            end
          else
            delete_user = users_Obj.remove_user_with_role_from_space(params[:current_organization], params[:thisUser], params[:thisUserRole])

            if delete_user == 'error'
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=delete_user'
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            end
          end
        end

      end
    end
  end
end