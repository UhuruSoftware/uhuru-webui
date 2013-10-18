module Uhuru::Webui
  module SinatraRoutes
    module Domains
      def self.registered(app)
        app.get DOMAINS_CREATE do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
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
          require_login
          wildcard = params[:domain_wildcard] ? true : false

          begin
            Library::Domains.new(session[:token], $cf_target).create(params[:domainName], params[:org_guid], wildcard, params[:space_guid])

            if params[:current_tab].to_s == 'space'
              switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains"
            else
              switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/domains"
            end
          rescue CFoundry::DomainInvalid => e
            if params[:current_tab].to_s == 'space'
              switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains/map_domain/new" + "?error=#{e.description}"
            else
              switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/domains/add_domains" + "?error=#{e.description}"
            end
          end
        end

        app.post '/deleteDomain' do
          require_login
          Library::Domains.new(session[:token], $cf_target).delete(params[:domainGuid])
          switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/domains"
        end

        app.post '/unmapFromSpace' do
          require_login
          Library::Domains.new(session[:token], $cf_target).unmap_domain(params[:domainGuid], nil, params[:current_space])

          if params[:current_tab].to_s == 'space'
            switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/domains"
          else
            switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/domains"
          end
        end
      end
    end
  end
end