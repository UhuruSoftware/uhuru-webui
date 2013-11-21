#
#   NOTE: Get and post methods for the organizations page and organization tiles
#
module Uhuru::Webui
  module SinatraRoutes
    module Organizations
      def self.registered(app)

        # Get method for reading all the organizations
        app.get ORGANIZATIONS do
          require_login
          organizations_list = Library::Organizations.new(session[:token], $cf_target).read_all(session[:user_guid])
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

        # Get method for the create organization modal
        app.get ORGANIZATIONS_CREATE do
          require_login
          organizations_list = Library::Organizations.new(session[:token], $cf_target).read_all(session[:user_guid])
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

        # Create organization post method (creates a new organization)
        app.post '/createOrganization' do
          require_login

          if $config[:billing][:provider] == 'stripe'
            if params[:stripeToken] == nil
              return {:error => "Could retrieve your credit card information. Please contact support."}.to_json
            end
          end

          if params[:orgName].size < 4
            return {:error => "The name is too short (min. 4 characters)"}.to_json
          end

          begin
            create = Library::Organizations.new(session[:token], $cf_target).create($config, params[:orgName], session[:user_guid])
          rescue CFoundry::OrganizationNameTaken => ex
            if params[:stripeToken] == nil
              return {:error => "#{ex.description}"}.to_json
            else
              return {:error => "#{ex.description}"}.to_json
            end
          end

          begin
            customer = Uhuru::Webui::Billing::Provider.provider.create_customer(session[:username], params[:stripeToken])
            Uhuru::Webui::Billing::Provider.provider.add_billing_binding(customer, create)
          rescue => ex
            $logger.error("Error while trying to create an org for #{session[:user_guid]} - #{ex.message}:#{ex.backtrace}")
            #the following if and the 'if params[:stripeToken] == nil' from OrganizationNameTaken exception, is a an check
            #for the case when the org has been created but the stripe operation goes in timeout(30 seconds),
            #so the second time when post is called would have been displayed a OrganizationNameTaken but the org and
            #the credit card would have been created
            if !ex.message.include?("You cannot use a Stripe token more than once")
              Library::Organizations.new(session[:token], $cf_target).delete($config, create)
              return {:error => "Error while trying to create an org: #{ex.message}"}.to_json
            end
          end

          return {:error => "OK"}.to_json
        end

        # Post method for deleting an organization
        app.post '/deleteOrganization' do
          require_login

          org = Library::Organizations.new(session[:token], $cf_target)
          is_an_owner = false

          #this is a an double check that prevents a 500 error to be displayed for the case when an org has been deleted,
          #but the stripe operation goes in timeout(30 seconds), so the second time when post is called
          #a 500 error would have been displayed
          if org.org_exists?(params[:orgGuid])
            org.read_owners($config, params[:orgGuid]).each do |owner|
              if owner.email == session[:username]
                is_an_owner = true
              end
            end

            #we should raise an error if an auditor or billing manager tries to delete an organization
            if is_an_owner
              Library::Organizations.new(session[:token], $cf_target).delete($config, params[:orgGuid])
              begin
                Uhuru::Webui::Billing::Provider.provider.delete_credit_card_org(params[:orgGuid])
              rescue => ex
                $logger.error("Error while trying to delete an org for #{session[:user_guid]} - #{ex.message}:#{ex.backtrace}")
                return switch_to_get "/deleteOrganization?error=Error while trying to delete an org: #{ex.message}"
              end

            else
              return switch_to_get "#{ORGANIZATIONS}" + "?error=You are not authorized to remove this organization."
            end
          end

          redirect ORGANIZATIONS
        end

        # Update organization method
        app.post '/updateOrganization' do
          require_login

          if params[:modified_name].size >= 4
            begin
              Library::Organizations.new(session[:token], $cf_target).update(params[:modified_name], params[:current_organization])
              return switch_to_get "#{ORGANIZATIONS}/#{params[:current_organization]}/#{params[:current_tab]}"
            rescue CFoundry::OrganizationNameTaken => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            rescue CFoundry::NotAuthorized => ex
              $logger.error("#{ex.message}:#{ex.backtrace}")
              return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{ex.description}"
            end
          else
            return switch_to_get ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + '?error=The name is too short (min. 4 characters)'
          end
        end

        # Get method for change credit card modal
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
                      :org_guid => params[:org_guid],
                      :error_message => error_message,
                      :months => months,
                      :years => years,
                      :countries => countries,
                      :card => card
                  }
              }
        end

        # Post method for change credit card modal
        app.post CHANGE_CARD do
          require_login

          if $config[:billing][:provider] == 'stripe'
            if params[:stripeToken] == nil
              return switch_to_get "#{CHANGE_CARD}?error=Could retrieve your credit card information. Please contact support."
            end
          end

          begin
            Uhuru::Webui::Billing::Provider.provider.update_credit_card(params[:org_guid], params[:stripeToken])
          rescue => ex
            $logger.error("Error while trying to change credit card information for #{session[:user_guid]} - #{ex.message}:#{ex.backtrace}")
            #the following if is a an check for the case when the stripe operation goes in timeout(30 seconds),
            #so the second time when post is called if the message 'You cannot use a Stripe token more than once'
            #would have been displayed, the credit card info was already updated and there's no need to show this message to the user
            if !ex.message.include?("You cannot use a Stripe token more than once")
              return switch_to_get "#{Uhuru::Webui::SinatraRoutes::ORGANIZATIONS}/#{params[:org_guid]}/credit_cards/change_credit_card?error=Error while trying to change credit card information: #{ex.message}"
            end
          end

          switch_to_get "#{Uhuru::Webui::SinatraRoutes::ORGANIZATIONS}/#{params[:org_guid]}/credit_cards"
        end

      end
    end
  end
end