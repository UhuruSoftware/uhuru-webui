require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Spaces
      def self.registered(app)

        app.get ORGANIZATION do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          org.set_current_org(params[:org_guid])

          spaces_list = org.read_spaces(params[:org_guid])
          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          domains_list = domain.read_domains(params[:org_guid])

          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :spaces_list => spaces_list,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :domains_list => domains_list,
                      :error_message => error_message
                  }
              }
        end

        app.get SPACES_CREATE do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          org.set_current_org(params[:org_guid])

          spaces_list = org.read_spaces(params[:org_guid])
          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          domains_list = domain.read_domains()

          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :spaces_list => spaces_list,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/spaces_create'
                  }
              }
        end

        app.get SPACE do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          user = UsersSetup.new($config)
          route = Library::Routes.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          space.set_current_space(params[:space_guid])

          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          routes_list = route.read_routes(params[:space_guid])
          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])
          domains_list = domain.read_domains(params[:org_guid], params[:space_guid])

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
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :routes_list => routes_list,
                      :domains_list => domains_list,
                      :error_message => error_message
                  }
              }
        end

        app.post '/createSpace' do
          if params[:spaceName].size >= 4
            create = Library::Spaces.new(session[:token], $cf_target).create(params[:org_guid], params[:spaceName])
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + '?error=The space name is to short.'
          end

          if defined?(create.message)
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + "?error=#{create.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
          end
        end

        app.post '/deleteSpace' do
          delete = Library::Spaces.new(session[:token], $cf_target).delete(params[:spaceGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces" + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
          end
        end

        app.post '/updateSpace' do
          if params[:modified_name].size >= 4
            update = Library::Spaces.new(session[:token], $cf_target).update(params[:modified_name], params[:current_space])
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=The space name is to short.'
          end

          if defined?(update.message)
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + "?error=#{update.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end