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

        app.get APP_RUNNING_INSTANCES do
          require_login
          Applications.new(session[:token], $cf_target).get_app_running_status(params[:app_guid]).to_json
        end
        
        app.get APP_CREATE do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          domain = Library::Domains.new(session[:token], $cf_target)

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
          require_login
          collection = TemplateApps.new
          apps = collection.read_collections
          app_id = params[:app_id]
          content_type 'image/png'
          send_file apps[app_id]['logo']
        end

        app.post '/get_service_data' do
          require_login
          space = Library::Spaces.new(session[:token], $cf_target)
          services = space.read_service_instances(params[:current_space])
          service = services.find { |s| s.name.to_s == params[:service_name].to_s }
          "{ \"type\": \"#{service.type}\", \"plan\": \"#{service.plan}\" } "
        end

        app.get '/download_app/:app_id' do
          require_login
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
                      :modal_title => "Pushing your application ...",
                      :include_erb => :'user_pages/modals/cloud_feedback'
                  }
              }
        end

        app.get APP_UPDATE_FEEDBACK do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)

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
                      :modal_title => "Updating your application ...",
                      :include_erb => :'user_pages/modals/cloud_feedback'
                  }
              }
        end

        app.post '/push' do
          require_login

          name = params[:app_name]
          domain_name = params[:app_domain]
          host_name = params[:app_host]
          memory = params[:app_memory]
          instances = params[:app_instances]
          src = params[:app_src] + params[:app_id] + '.zip'

          location = File.expand_path(params[:app_src] + 'manifest.yml', __FILE__)
          manifest = YAML.load_file location
          service_list = manifest['applications'][0]['services'] || []
          app_services = []
          service_list.each do |service|
            app_services << { :name => "#{name}DB-#{SecureRandom.uuid.slice(0, 5)}", :type => service[1]['label'], :plan => service[1]['plan'] }
          end

          stack = manifest['applications'][0]['stack']
          buildpack = manifest['applications'][0]['buildpack']
          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.start_feedback

          Thread.new() do
            begin
              apps_obj.create!(params[:app_space], name, instances.to_i, memory.to_i, domain_name, host_name, src, app_services, stack, buildpack)
            rescue => e
              apps_obj.info_ln('')
              apps_obj.error_ln('There was an error while processing the push request - please contact support')
              $logger.error("Push error: #{e.message} - #{e.backtrace}")
            ensure
              apps_obj.close_feedback
            end
          end

          switch_to_get "#{ORGANIZATIONS}/#{params[:app_organization]}/spaces/#{params[:app_space]}/apps/create_app_feedback/#{apps_obj.id}"
        end

        app.post '/updateApp' do
          require_login
          apps_object = Applications.new(session[:token], $cf_target)
          apps_object.start_feedback

          space = Library::Spaces.new(session[:token], $cf_target)
          apps_list = space.read_apps(params[:current_space])

          Thread.new() do
            begin
              binding_object = Library::Routes.new(session[:token], $cf_target)
              apps_object.update(params[:app_name], params[:app_state], params[:app_instances].to_i, params[:app_memory].to_i, params[:app_services], params[:app_urls], binding_object, params[:current_space], apps_list)
            rescue => e
              apps_object.info_ln('')
              apps_object.error_ln('There was an error while processing the update request - please contact support')
              $logger.error("Update error: #{e.message} - #{e.backtrace}")
            ensure
              apps_object.close_feedback
            end

            apps_object.close_feedback
          end

          switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/apps/update_app_feedback/#{apps_object.id}"
        end

        app.post '/deleteApp' do
          require_login
          Applications.new(session[:token], $cf_target).delete(params[:appGuid])
          switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
        end
      end
    end
  end
end