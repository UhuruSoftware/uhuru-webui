module Uhuru::Webui
  module SinatraRoutes
    module Users
      def self.registered(app)
        app.get ORGANIZATION_MEMBERS_ADD do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          org.set_current_org(params[:org_guid])

          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end

        app.get SPACE_MEMBERS_ADD do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          space.set_current_space(params[:space_guid])

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])
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
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :developers_list => developers_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end

        app.post '/addUser' do
          require_login
          user = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            begin
              user.invite_user_with_role_to_org($config, params[:userEmail], params[:current_organization], params[:userType])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            rescue Library::Users::UserError => e
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + "?error=#{e.description}"
            end
          else
            begin
              user.invite_user_with_role_to_space($config, params[:userEmail], params[:current_space], params[:userType])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            rescue Library::Users::UserError => e
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + "?error=#{e.description}"
            end
          end
        end

        app.post '/deleteUser' do
          require_login
          user = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            begin
              user.remove_user_with_role_from_org(params[:current_organization], params[:thisUser], params[:thisUserRole])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            rescue Library::Users::UserError => e
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{e.description}"
            end
          else
            begin
              user.remove_user_with_role_from_space(params[:current_space], params[:thisUser], params[:thisUserRole])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            rescue Library::Users::UserError => e
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{e.description}"
            end
          end
        end
      end
    end
  end
end