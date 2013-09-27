require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Users
      def self.registered(app)

        app.get ORGANIZATION_MEMBERS_ADD do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          user = UsersSetup.new($config)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_users = user.uaa_get_usernames

          org.set_current_org(params[:org_guid])
          spaces_list = org.read_spaces(params[:org_guid])
          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          domains_list = domain.read_domains()

          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :all_users => all_users,
                      :spaces_list => spaces_list,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end

        app.get SPACE_MEMBERS_ADD do
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
          domains_list = domain.read_domains(params[:org_guid], params[:space_guid])

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
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end




        app.post '/addUser' do
          user = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            add_user = user.invite_user_with_role_to_org($config, params[:userEmail], params[:current_organization], params[:userType])

            if defined?(add_user.message)
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + "?error=#{add_user.description}"
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            end
          else
            add_user = user.invite_user_with_role_to_space($config, params[:userEmail], params[:current_space], params[:userType])

            if defined?(add_user.message)
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + "?error=#{add_user.description}"
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            end
          end
        end

        app.post '/deleteUser' do
          user = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            delete_user = user.remove_user_with_role_from_org(params[:current_organization], params[:thisUser], params[:thisUserRole])

            if defined?(delete_user.message)
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{delete_user.description}"
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            end
          else
            delete_user = user.remove_user_with_role_from_space(params[:current_space], params[:thisUser], params[:thisUserRole])

            if defined?(delete_user.message)
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{delete_user.description}"
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            end
          end
        end

      end
    end
  end
end