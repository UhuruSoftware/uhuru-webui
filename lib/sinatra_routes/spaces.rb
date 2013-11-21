#
#   NOTE: Get and post methods for the spaces tab tab
#
module Uhuru::Webui
  module SinatraRoutes
    module Spaces
      def self.registered(app)

        # Get method for a defined organization (reads all the spaces, users, domains and the organization credit card)
        app.get ORGANIZATION do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)

          organization_name = org.get_name(params[:org_guid])
          organization_guid = params[:org_guid]

          see_cards = Library::Users.new(session[:token], $cf_target).check_user_org_roles(organization_guid, session[:user_guid], ["owner", "billing"])

          error_message = params[:error] if defined?(params[:error])

          case params[:tab]
            when 'spaces'
              spaces_list = org.read_spaces(params[:org_guid])
              erb :'user_pages/organization',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :current_organization => organization_guid,
                          :current_tab => params[:tab],
                          :spaces_list => spaces_list,
                          :see_cards => see_cards,
                          :error_message => error_message
                      }
                  }
            when 'members'
              owners_list = org.read_owners($config, params[:org_guid])
              billings_list = org.read_billings($config, params[:org_guid])
              auditors_list = org.read_auditors($config, params[:org_guid])
              erb :'user_pages/organization',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :current_organization => organization_guid,
                          :current_tab => params[:tab],
                          :owners_list => owners_list,
                          :billings_list => billings_list,
                          :auditors_list => auditors_list,
                          :see_cards => see_cards,
                          :error_message => error_message
                      }
                  }
            when 'domains'
              domains_list = domain.read_domains(params[:org_guid])
              erb :'user_pages/organization',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :current_organization => organization_guid,
                          :current_tab => params[:tab],
                          :domains_list => domains_list,
                          :see_cards => see_cards,
                          :error_message => error_message
                      }
                  }
            when 'credit_cards'
              credit_card = Uhuru::Webui::Billing::Provider.provider.read_credit_card_org(organization_guid)
              erb :'user_pages/organization',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :current_organization => organization_guid,
                          :current_tab => params[:tab],
                          :credit_card => credit_card,
                          :see_cards => see_cards,
                          :error_message => error_message
                      }
                  }
            else
              raise Sinatra::NotFound.new
          end
        end

        # Crete space modal
        app.get SPACES_CREATE do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)

          spaces_list = org.read_spaces(params[:org_guid])
          see_cards = Library::Users.new(session[:token], $cf_target).check_user_org_roles(params[:org_guid], session[:user_guid], ["owner", "billing"])
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :spaces_list => spaces_list,
                      :see_cards => see_cards,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/spaces_create'
                  }
              }
        end

        # Get method for a defined space (reads all apps, services, routes, domains and users from the space)
        app.get SPACE do
          require_login

          begin
            org = Library::Organizations.new(session[:token], $cf_target)
            space = Library::Spaces.new(session[:token], $cf_target)
            app = TemplateApps.new
            route = Library::Routes.new(session[:token], $cf_target)
            domain = Library::Domains.new(session[:token], $cf_target)

            organization_name = org.get_name(params[:org_guid])
            space_name = space.get_name(params[:space_guid])

            collections = app.read_collections
            error_message = params[:error] if defined?(params[:error])
          rescue CFoundry::NotAuthorized => e
            return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces" + "?error=#{e.description}"
          end

          case params[:tab]
            when 'apps'
              apps_list = space.read_apps(params[:space_guid])
              erb :'user_pages/space',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :space_name => space_name,
                          :current_organization => params[:org_guid],
                          :current_space => params[:space_guid],
                          :current_tab => params[:tab],
                          :collections => collections,
                          :apps_list => apps_list,
                          :error_message => error_message
                      }
                  }
            when 'services'
              services_list = space.read_service_instances(params[:space_guid])
              erb :'user_pages/space',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :space_name => space_name,
                          :current_organization => params[:org_guid],
                          :current_space => params[:space_guid],
                          :current_tab => params[:tab],
                          :collections => collections,
                          :services_list => services_list,
                          :error_message => error_message
                      }
                  }
            when 'members'
              owners_list = space.read_owners($config, params[:space_guid])
              developers_list = space.read_developers($config, params[:space_guid])
              auditors_list = space.read_auditors($config, params[:space_guid])
              erb :'user_pages/space',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :space_name => space_name,
                          :current_organization => params[:org_guid],
                          :current_space => params[:space_guid],
                          :current_tab => params[:tab],
                          :collections => collections,
                          :owners_list => owners_list,
                          :auditors_list => auditors_list,
                          :developers_list => developers_list,
                          :error_message => error_message
                      }
                  }
            when 'routes'
              routes_list = route.read_routes(params[:space_guid])
              erb :'user_pages/space',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :space_name => space_name,
                          :current_organization => params[:org_guid],
                          :current_space => params[:space_guid],
                          :current_tab => params[:tab],
                          :collections => collections,
                          :routes_list => routes_list,
                          :error_message => error_message
                      }
                  }
            when 'domains'
              domains_list = domain.read_domains(params[:org_guid], params[:space_guid])
              erb :'user_pages/space',
                  {
                      :layout => :'layouts/user',
                      :locals => {
                          :organization_name => organization_name,
                          :space_name => space_name,
                          :current_organization => params[:org_guid],
                          :current_space => params[:space_guid],
                          :current_tab => params[:tab],
                          :collections => collections,
                          :domains_list => domains_list,
                          :error_message => error_message
                      }
                  }
            else
              raise Sinatra::NotFound.new
          end
        end

        # Post method for create space modal
        app.post '/createSpace' do
          require_login

          if params[:spaceName].size >= 4
            begin
              Library::Spaces.new(session[:token], $cf_target).create(params[:org_guid], params[:spaceName])
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
            rescue CFoundry::SpaceNameTaken => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + "?error=#{ex.description}"
            rescue CFoundry::NotAuthorized => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + "?error=#{ex.description}"
            end
          else
            return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + '?error=The space name is to short.'
          end
        end

        # Post method for delete space modal
        app.post '/deleteSpace' do
          require_login
          begin
            delete = Library::Spaces.new(session[:token], $cf_target).delete(params[:spaceGuid])
            #delete space may not raise an API error, so we should check it manually3
            if delete == false
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces" + "?error=You are not authorized to delete this space."
            end

          rescue CFoundry::NotAuthorized => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces" + "?error=#{ex.description}"
          end
          switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
        end

        # Post method for update space name
        app.post '/updateSpace' do
          require_login

          if params[:modified_name].size >= 4
            begin
              Library::Spaces.new(session[:token], $cf_target).update(params[:modified_name], params[:current_space])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            rescue CFoundry::SpaceNameTaken => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            rescue CFoundry::NotAuthorized => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            end
          else
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=The space name is to short.'
          end
        end
      end
    end
  end
end