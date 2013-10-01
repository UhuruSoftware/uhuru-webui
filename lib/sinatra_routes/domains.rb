require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Domains
      def self.registered(app)

        app.get DOMAINS_CREATE do
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
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/domains_create'
                  }
              }
        end

        app.get DOMAINS_MAP_SPACE do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          route = Library::Routes.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          org.set_current_org(params[:org_guid])
          space.set_current_space(params[:space_guid])

          spaces_list = org.read_spaces(params[:org_guid])
          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          routes_list = route.read_routes(params[:space_guid])
          domains_list = domain.read_domains()
          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])

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
                      :spaces_list => spaces_list,
                      :collections => collections,
                      :owners_list => owners_list,
                      :developers_list => developers_list,
                      :auditors_list => auditors_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :routes_list => routes_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/domains_map_space'
                  }
              }
        end

        app.post '/createDomain' do
          wildcard = params[:domain_wildcard] ? true : false
          create = Library::Domains.new(session[:token], $cf_target).create(params[:domainName], params[:org_guid], wildcard, params[:space_guid])

          if defined?(create.message)
            if params[:current_tab].to_s == 'space'
              redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains/map_domain/new" + "?error=#{create.description}"
            else
              redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains/add_domains" + "?error=#{create.description}"
            end
          else
            if params[:current_tab].to_s == 'space'
              redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains"
            else
              redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains"
            end
          end
        end

        app.post '/deleteDomain' do
          delete = Library::Domains.new(session[:token], $cf_target).delete(params[:domainGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains" + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains"
          end
        end

        app.post '/unmapFromSpace' do
          unmap = Library::Domains.new(session[:token], $cf_target).unmap_domain(params[:domainGuid], nil, params[:current_space])

          if defined?(unmap.message)
            if params[:current_tab].to_s == 'space'
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/domains" + "?error=#{unmapp.description}"
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/domains" + "?error=#{unmapp.description}"
            end
          else
            if params[:current_tab].to_s == 'space'
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/domains"
            else
              redirect ORGANIZATIONS + "/#{params[:current_organization]}/domains"
            end
          end
        end

      end
    end
  end
end