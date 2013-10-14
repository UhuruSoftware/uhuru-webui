require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Domains
      def self.registered(app)

        app.get DOMAINS_CREATE do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          org.set_current_org(params[:org_guid])
          domains_list = domain.read_domains(params[:org_guid])

          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/domains_create'
                  }
              }
        end

        app.get DOMAINS_MAP_SPACE do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          org.set_current_org(params[:org_guid])
          space.set_current_space(params[:space_guid])

          domains_list = domain.read_domains(nil, params[:space_guid])

          domains_list_org = domain.read_domains(params[:org_guid])

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
                      :domains_list => domains_list,
                      :domains_list_org => domains_list_org,
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