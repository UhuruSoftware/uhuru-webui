require 'sinatra/base'


#
#    TODO:: There are some variables in this code that should not be hardcoded
#


module Uhuru::Webui
  module SinatraRoutes
    module Apps
      def self.registered(app)

        app.get APP do

          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          domain = Library::Domains.new(session[:token], $cf_target)
          space.set_current_space(params[:space_guid])

          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          domains_list = domain.read_domains()
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
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :app => params[:app]
                      #does not need to include an erb, the app details erb is a bigger modal
                  }
              }
        end

        app.get APP_CREATE do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          domain = Library::Domains.new(session[:token], $cf_target)
          space.set_current_space(params[:space_guid])

          apps_list = space.read_apps(params[:space_guid])
          domains_list = domain.read_domains()
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
                      :apps => collections,
                      :apps_list => apps_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/apps_create'
                  }
              }
        end

        app.get '/get_logo/:app_id' do
          collection = TemplateApps.new
          apps = collection.read_collections
          app_id = params[:app_id]
          content_type 'image/png'
          send_file apps[app_id]['logo']
        end

        app.post '/get_service_data' do
          space = Library::Spaces.new(session[:token], $cf_target)
          space.set_current_space(params[:current_space])
          services = space.read_service_instances(params[:current_space])
          service = services.find { |s| s.name.to_s == params[:service_name].to_s }

          "{ \"type\": \"#{service.type}\", \"plan\": \"#{service.plan}\" } "
        end

        app.get '/download_app/:app_id' do
          collection = TemplateApps.new
          apps = collection.read_collections
          source = nil

          apps.each do |app|
            if app[1]['id'] == params[:app_id]
              source = app[1]['app_src']
            end
          end

          send_file(source.sub!'template_manifest.yml', params[:app_id] + '.zip')
        end

        app.get APP_CREATE_FEEDBACK do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)

          space.set_current_space(params[:space_guid])
          apps_list = space.read_apps(params[:space_guid])

          erb :'user_pages/space',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :space_name => space.get_name(params[:space_guid]),
                      :current_organization => params[:org_guid],
                      :current_space => params[:space_guid],
                      :current_tab => params[:tab],
                      :apps_list => apps_list,
                      :feedback_id => params[:id],
                      :error_message => nil,
                      :include_erb => :'user_pages/modals/cloud_feedback'
                  }
              }
        end

        app.get APP_UPDATE_FEEDBACK do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)

          space.set_current_space(params[:space_guid])
          apps_list = space.read_apps(params[:space_guid])

          erb :'user_pages/space',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :space_name => space.get_name(params[:space_guid]),
                      :current_organization => params[:org_guid],
                      :current_space => params[:space_guid],
                      :current_tab => params[:tab],
                      :apps_list => apps_list,
                      :feedback_id => params[:id],
                      :error_message => nil,
                      :include_erb => :'user_pages/modals/cloud_feedback'
                  }
              }
        end

        app.post '/push' do
          name = params[:app_name]
          url = params[:app_url]
          memory = params[:app_memory]
          instances = params[:app_instances]
          src = params[:app_src] + params[:app_id] + '.zip'
          plan = "free"

          location = File.expand_path(params[:app_src] + 'vmc_manifest.yml', __FILE__)
          manifest = YAML.load_file location
          service_list = manifest['applications'][0]['services'] || []
          app_services = []
          service_list.each do |service|
            app_services << { :name => service[0], :type => service[1]['label'] }
          end

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.start_feedback

          Thread.new() do
            apps_obj.create!(params[:app_organization], params[:app_space], name, instances.to_i, memory.to_i, url, src, plan, app_services)
            apps_obj.close_feedback
          end

          redirect "#{ORGANIZATIONS}/#{params[:app_organization]}/spaces/#{params[:app_space]}/apps/create_app_feedback/#{apps_obj.id}"
        end



        app.post '/updateApp' do
          apps_object = Applications.new(session[:token], $cf_target)
          apps_object.start_feedback

          Thread.new() do
            apps_object.update(params[:name], params[:state], params[:instances].to_i, params[:memory].to_i)

            #.unbind_app_url(params[:appName], params[:appUrl])
            #.unbind_app_services(params[:appName], params[:serviceName])
            ##bind URL
            #domain_guid = Library::Domains.new(session[:token], $cf_target).get_organizations_domain_guid(params[:current_organization])
            #bind = Library::Routes.new(session[:token], $cf_target).create(params[:appName], params[:current_space], params[:domain], params[:host])
            ###
            #.bind_app_services(params[:appName], params[:serviceName])
            #.stop_app(params[:appName])
            #.start_app(params[:appName])

            apps_object.close_feedback
          end

          redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/apps/update_app_feedback/#{apps_object.id}"
        end



        app.post '/deleteApp' do
          delete = Applications.new(session[:token], $cf_target).delete(params[:appName])

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