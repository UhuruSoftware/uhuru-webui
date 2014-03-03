#
#   NOTE: Get and post methods for the routes tab
#
module Uhuru::Webui
  module SinatraRoutes
    module Routes
      def self.registered(app)

        # Get method for create routes modal
        app.get ROUTES_CREATE do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          route = Library::Routes.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)

          routes_list = route.read_routes(params[:space_guid])
          domains_list_space = domain.read_domains(params[:org_guid], params[:space_guid])
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
                      :routes_list => routes_list,
                      :domains_list_space => domains_list_space,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/routes_create'
                  }
              }
        end

        # Post method for create routes modal
        app.post '/createRoute' do
          require_login

          begin
            Library::Routes.new(session[:token], $cf_target).create(nil, params[:current_space], params[:domain_guid], params[:host])
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          rescue CFoundry::RouteInvalid => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_route/new" + "?error=#{ex.description}"
          rescue CFoundry::RouteHostTaken => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_route/new" + "?error=#{ex.description}"
          rescue CFoundry::NotAuthorized => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_route/new" + "?error=#{ex.description}"
          end
        end

        # Post method for delete routes
        app.post '/deleteRoute' do
          require_login
          begin
            Library::Routes.new(session[:token], $cf_target).delete(params[:routeGuid])
          rescue CFoundry::NotAuthorized => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{ex.description}"
          end
          switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
        end
      end
    end
  end
end