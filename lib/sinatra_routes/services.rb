require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Services
      def self.registered(app)
        app.get SERVICES_CREATE do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          space.set_current_space(params[:space_guid])

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

        app.post '/createService' do
          require_login

          if params[:serviceName].size >= 4
            create = ServiceInstances.new(session[:token], $cf_target).create_service_instance(params[:serviceName], params[:current_space], params[:service_plan])
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + '?error=The service name is too short.'
          end

          if defined?(create.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/create_service/new" + "?error=#{create.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/deleteService' do
          require_login

          delete = ServiceInstances.new(session[:token], $cf_target).delete(params[:serviceGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end