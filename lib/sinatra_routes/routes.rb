module Uhuru::Webui
  module SinatraRoutes
    module Routes
      def self.registered(app)
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

        app.post '/createRoute' do
          require_login

          begin
            Library::Routes.new(session[:token], $cf_target).create(nil, params[:current_space], params[:domain_guid], params[:host])
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          rescue CFoundry::RouteInvalid => e
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/add_route/new" + "?error=#{e.description}"
          end
        end

        app.post '/deleteRoute' do
          require_login
          Library::Routes.new(session[:token], $cf_target).delete(params[:routeGuid])
          switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
        end
      end
    end
  end
end