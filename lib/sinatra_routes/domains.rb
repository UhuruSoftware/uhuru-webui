#
#   NOTE: the get and post methods for the domain tab
#
module Uhuru::Webui
  module SinatraRoutes
    module Domains
      def self.registered(app)

        # Get method for the create domain modal
        app.get DOMAINS_CREATE do
          require_login
          org = Library::Organizations.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          domains_list = domain.read_domains(params[:org_guid])
          see_cards = Library::Users.new(session[:token], $cf_target).check_user_org_roles(params[:org_guid], session[:user_guid], ["owner", "billing"])
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :domains_list => domains_list,
                      :see_cards => see_cards,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/domains_create'
                  }
              }
        end

        # Get method for the map domain modal inside a space
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

        # Post method for the create domain(if inside an org) or map a domain to the current space(if inside a space)
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

          rescue CFoundry::DomainInvalid => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            if params[:current_tab].to_s == 'space'
              switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains/map_domain/new" + "?error=#{ex.description}"
            else
              switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/domains/add_domains" + "?error=#{ex.description}"
            end

          rescue CFoundry::NotAuthorized => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            if params[:current_tab].to_s == 'space'
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains/map_domain/new" + "?error=#{ex.description}"
            else
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/domains/add_domains" + "?error=#{ex.description}"
            end
          end
        end

        # Post method for the delete domain
        app.post '/deleteDomain' do
          require_login
          begin
            delete = Library::Domains.new(session[:token], $cf_target).delete(params[:domainGuid])
            if delete == false
              return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains" + "?error=There was an error removing this domain, if the problem persists please contact support."
            end
          rescue CFoundry::NotAuthorized => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/spaces/#{params[:space_guid]}/domains" + "?error=#{ex.description}"
          end
          switch_to_get ORGANIZATIONS + "/#{params[:org_guid]}/domains"
        end

        # Post method for unmapping a domain from a space
        app.post '/unmapFromSpace' do
          require_login
          begin
            Library::Domains.new(session[:token], $cf_target).unmap_domain(params[:domainGuid], nil, params[:current_space])
          rescue CFoundry::NotAuthorized => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            if params[:current_tab].to_s == 'space'
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/domains" + "?error=#{ex.description}"
            else
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/domains" + "?error=#{ex.description}"
            end
          end

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