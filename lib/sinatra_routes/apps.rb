require 'sinatra/base'


#
#    TODO:: There are some variables in this code that should not be hardcoded
#


module Uhuru::Webui
  module SinatraRoutes
    module Apps
      def self.registered(app)

        app.get APP do

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

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])
          @domains_list = domain.read_domains()

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
                      :error_message => error_message,
                      :app => params[:app]
                  }
              }
        end

        app.get APP_CREATE do

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

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])
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
                      :all_space_users => all_space_users,
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :routes_list => routes_list,
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

        app.post '/push' do
          name = params[:app_name]
          url = params[:app_url]
          memory = params[:app_memory]
          instances = params[:app_instances]
          src = params[:app_src] + params[:app_id] + '.zip'
          plan = "free"

          location = File.expand_path(params[:app_src] + 'vmc_manifest.yml', __FILE__)
          manifest = YAML.load_file location
          service_list = manifest['applications']['.']['services'] || []
          app_services = []
          service_list.each do |service|
            app_services << { :name => service[0], :type => service[1]['type'] }
          end

          apps_obj = Applications.new(session[:token], $cf_target)
          push = apps_obj.create(params[:app_organization], params[:app_space], name, instances.to_i, memory.to_i, url, src, plan, app_services)

          if defined?(push.message)
            redirect ORGANIZATIONS + "/#{params[:app_organization]}/spaces/#{params[:app_space]}/apps/create_app/new" + "?error=#{push.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:app_organization]}/spaces/#{params[:app_space]}/apps/create_app/new"
          end
        end



        app.post '/deleteApp' do
          delete = Applications.new(session[:token], $cf_target).delete(params[:appGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

        app.post '/startApp' do
          start = Applications.new(session[:token], $cf_target).start_app(params[:appName])

          if defined?(start.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{start.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/stopApp' do
          stop = Applications.new(session[:token], $cf_target).stop_app(params[:appName])

          if defined?(stop.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{stop.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/updateApp' do
          update = Applications.new(session[:token], $cf_target).update(params[:appName], params[:appInstances].to_i, params[:appMemory].to_i)

          if defined?(update.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{update.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end




        app.post '/bindServices' do
          bind = Applications.new(session[:token], $cf_target).bind_app_services(params[:appName], params[:serviceName])

          if defined?(bind.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{bind.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/bindUri' do
          domain_guid = Library::Domains.new(session[:token], $cf_target).get_organizations_domain_guid(params[:current_organization])
          bind = Library::Routes.new(session[:token], $cf_target).create(params[:appName], params[:current_space], params[:domain], params[:host])

          if defined?(bind.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{bind.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/unbindServices' do
          unbind = Applications.new(session[:token], $cf_target).unbind_app_services(params[:appName], params[:serviceName])

          if defined?(unbind.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{unbind.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

        app.post '/unbindUri' do
          unbind = Applications.new(session[:token], $cf_target).unbind_app_url(params[:appName], params[:appUrl])

          if defined?(unbind.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}" + "?error=#{unbind.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}/#{params[:appName]}"
          end
        end

      end
    end
  end
end