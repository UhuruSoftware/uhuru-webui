module Uhuru::Webui
  module SinatraRoutes
    module Organizations
      def self.registered(app)
        app.get ORGANIZATIONS do
          require_login
          organizations_list = Library::Organizations.new(session[:token], $cf_target).read_all
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :error_message => error_message
                  }
              }
        end

        app.get ORGANIZATIONS_CREATE do
          require_login
          organizations_list = Library::Organizations.new(session[:token], $cf_target).read_all
          error_message = params[:error] if defined?(params[:error])

          months = Uhuru::Webui::Billing::Provider.months
          years = Uhuru::Webui::Billing::Provider.years
          countries = Uhuru::Webui::Billing::Provider.countries

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :error_message => error_message,
                      :months => months,
                      :years => years,
                      :countries => countries,
                      :include_erb => :"user_pages/modals/organizations_create_#{ $config[:billing][:provider] }",
                  }
              }
        end

        app.post '/createOrganization' do
          require_login

          if $config[:billing][:provider] == 'stripe'
            if params[:stripeToken] == nil
              return switch_to_get "#{ORGANIZATIONS_CREATE}?error=Could retrieve your credit card information. Please contact support."
            end
          end

          if params[:orgName].size < 4
            return switch_to_get "#{ORGANIZATIONS_CREATE}?error=The name is too short (min. 4 characters)"
          end

          begin
            create = Library::Organizations.new(session[:token], $cf_target).create($config, params[:orgName], session[:user_guid])
          rescue CFoundry::OrganizationNameTaken => e
            return switch_to_get "#{ORGANIZATIONS_CREATE}?error=#{e.description}"
          end

          begin
            customer = Uhuru::Webui::Billing::Provider.provider.create_customer(session[:username], params[:stripeToken])
            Uhuru::Webui::Billing::Provider.provider.add_billing_binding(customer, create)
          rescue => e
            $logger.error("Error while trying to create an org for #{session[:user_guid]} - #{e.message}:#{e.backtrace}")
            Library::Organizations.new(session[:token], $cf_target).delete($config, create)
            return switch_to_get "#{ORGANIZATIONS_CREATE}?error=Could not setup your credit card information. Please contact support."
          end

          switch_to_get ORGANIZATIONS
        end

        app.post '/deleteOrganization' do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          is_an_owner = false
          org.read_owners($config, params[:orgGuid]).each do |owner|
            if owner.email == session[:username]
              is_an_owner = true
            end
          end

          #we should raise an error if an auditor or billing manager tries to delete an organization
          if is_an_owner
            Library::Organizations.new(session[:token], $cf_target).delete($config, params[:orgGuid])
            Uhuru::Webui::Billing::Provider.provider.delete_credit_card_org(params[:orgGuid])
          else
            return switch_to_get "#{ORGANIZATIONS}" + "?error=You are not authorized to remove this organization."
          end

          redirect ORGANIZATIONS
        end

        app.post '/updateOrganization' do
          require_login

          if params[:modified_name].size >= 4
            begin
              Library::Organizations.new(session[:token], $cf_target).update(params[:modified_name], params[:current_organization])
              return switch_to_get "#{ORGANIZATIONS}/#{params[:current_organization]}/#{params[:current_tab]}"
            rescue CFoundry::OrganizationNameTaken => e
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{e.description}"
            rescue CFoundry::NotAuthorized => e
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{e.description}"
            end
          else
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + '?error=The name is too short (min. 4 characters)'
          end
        end

        app.get CHANGE_CARD do
          require_login

          error_message = params[:error] if defined?(params[:error])

          months = Uhuru::Webui::Billing::Provider.months
          years = Uhuru::Webui::Billing::Provider.years
          countries = Uhuru::Webui::Billing::Provider.countries

          card = Uhuru::Webui::Billing::Provider.provider.read_credit_card_org(params[:org_guid])

          erb :"user_pages/modals/update_card_#{ $config[:billing][:provider] }",
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :current_organization => params[:org_guid],
                      :error_message => error_message,
                      :months => months,
                      :years => years,
                      :countries => countries,
                      :card => card
                  }
              }
        end

        app.post CHANGE_CARD do
          require_login

          if $config[:billing][:provider] == 'stripe'
            if params[:stripeToken] == nil
              return switch_to_get "#{CHANGE_CARD}?error=Could retrieve your credit card information. Please contact support."
            end
          end

          begin
            Uhuru::Webui::Billing::Provider.provider.update_credit_card_org(session[:username], params[:stripeToken], params[:org_guid])
          rescue => e
            p "#{e.message}:#{e.backtrace}"
            $logger.error("Error while trying to change credit card information for #{session[:user_guid]} - #{e.message}:#{e.backtrace}")
            return switch_to_get "#{Uhuru::Webui::SinatraRoutes::ORGANIZATIONS}/#{params[:org_guid]}/credit_cards/change_credit_card?error=Could not setup your credit card information. Please contact support."
          end

          switch_to_get "#{Uhuru::Webui::SinatraRoutes::ORGANIZATIONS}/#{params[:org_guid]}/credit_cards"
        end

      end
    end
  end
end