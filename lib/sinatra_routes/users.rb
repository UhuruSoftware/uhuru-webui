#
#   NOTE: Get and post methods for the users tab
#
module Uhuru::Webui
  module SinatraRoutes
    module Users
      def self.registered(app)

        # Add organization member modal
        app.get ORGANIZATION_MEMBERS_ADD do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)

          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])

          see_cards = Library::Users.new(session[:token], $cf_target).check_user_org_roles(params[:org_guid], session[:user_guid], ["owner", "billing"])

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
                      :see_cards => see_cards,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end

        # Add space member modal
        app.get SPACE_MEMBERS_ADD do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)

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

        # Post method for adding a user to organization (or to a space, if the space is defined the user is automatically added to the space)
        app.post '/addUser' do
          require_login
          user = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
              unless /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(params[:userEmail])
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + "?error=This is not a valid email address!"
              end

              begin
                user.invite_user_with_role_to_org($config, params[:userEmail], params[:current_organization], params[:userType])
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"

              rescue Library::Users::DoesNotExist => ex
                $logger.error("#{ex.message}:#{ex.backtrace}")
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + "?error=#{ex.description}"
              rescue Library::Users::IsNotActive => ex
                $logger.error("#{ex.message}:#{ex.backtrace}")
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + "?error=#{ex.description}"
              rescue CFoundry::NotAuthorized => ex
                $logger.error("#{ex.message}:#{ex.backtrace}")
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}/add_user" + "?error=#{ex.description}"
              end
          else

              unless /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(params[:userEmail])
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + "?error=This is not a valid email address!"
              end

              begin
                if !user.any_org_roles?($config, params[:current_organization], params[:userEmail])
                  user.invite_user_with_role_to_org($config, params[:userEmail], params[:current_organization], "auditor")
                end
                user.invite_user_with_role_to_space($config, params[:userEmail], params[:current_space], params[:userType])
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"

              rescue Library::Users::DoesNotExist => ex
                $logger.error("#{ex.message}:#{ex.backtrace}")
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + "?error=#{ex.description}"
              rescue Library::Users::IsNotActive => ex
                $logger.error("#{ex.message}:#{ex.backtrace}")
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + "?error=#{ex.description}"
              rescue CFoundry::NotAuthorized => ex
                $logger.error("#{ex.message}:#{ex.backtrace}")
                return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_user/new" + "?error=#{ex.description}"
              end
          end
        end

        # Delete a user from the organization (or from the space if the space is defined)
        app.post '/deleteUser' do
          require_login
          user = Library::Users.new(session[:token], $cf_target)

          if params[:current_space] == nil || params[:current_space] == ''
            begin
              user.remove_user_with_role_from_org(params[:current_organization], params[:thisUser], params[:thisUserRole])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
            rescue Library::Users::UserError => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            rescue CFoundry::NotAuthorized => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            end
          else
            begin
              user.remove_user_with_role_from_space(params[:current_space], params[:thisUser], params[:thisUserRole])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            rescue Library::Users::UserError => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            rescue CFoundry::NotAuthorized => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            end
          end
        end
      end
    end
  end
end