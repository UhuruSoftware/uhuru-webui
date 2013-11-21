#
#   NOTE: Get and post methods for the services tab
#
module Uhuru::Webui
  module SinatraRoutes
    module Services
      def self.registered(app)

        # Create service modal
        app.get SERVICES_CREATE do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)

          services_list = space.read_service_instances(params[:space_guid])
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
                      :services_list => services_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/services_create'
                  }
              }
        end

        # Post method for create service modal
        app.post '/createService' do
          require_login

          if params[:serviceName].size >= 4
            begin
              ServiceInstances.new(session[:token], $cf_target).create_service_instance(params[:serviceName], params[:current_space], params[:service_plan])
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
            rescue Exception => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + "?error=#{ex.description}"
            rescue CFoundry::NotAuthorized => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + "?error=#{ex.description}"
            end
          else
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + '?error=The service name is too short.'
          end
        end

        # Post method for delete service
        app.post '/deleteService' do
          require_login
          begin
            ServiceInstances.new(session[:token], $cf_target).delete(params[:serviceGuid])
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