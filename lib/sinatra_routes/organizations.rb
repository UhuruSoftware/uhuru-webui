require 'organizations'


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

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/organizations_create',
                  }
              }
        end

        app.post '/createOrganization' do

          if $config[:billing][:provider] == 'stripe'
            if params[:stripeToken] == nil
              redirect ORGANIZATIONS_CREATE + "?error=Could retrieve your credit card information. Please contact support."
            end
          end

          if params[:orgName].size < 4
            redirect ORGANIZATIONS_CREATE + '?error=The name is too short (min. 4 characters)'
          end

          create = Library::Organizations.new(session[:token], $cf_target).create($config, params[:orgName], session[:user_guid])

          if defined?(create.message)
            redirect ORGANIZATIONS_CREATE + "?error=#{create.description}"
          else
            if $config[:billing][:provider] == 'stripe'
              begin
                customer = Uhuru::Webui::Billing::Provider.provider.create_customer(session[:username], params[:stripeToken])
                Uhuru::Webui::Billing::Provider.provider.add_billing_binding(customer.id, create)
              rescue => e
                $logger.error("Error while trying to create an org for #{session[:user_guid]} - #{e.message}:#{e.backtrace}")
                Library::Organizations.new(session[:token], $cf_target).delete($config, create)
                redirect ORGANIZATIONS_CREATE + "?error=Could not setup your credit card information. Please contact support."
              end
            else
              # this else branch is a placeholder for Billing Provider 'none'
            end
          end
          redirect ORGANIZATIONS
        end


        app.post '/deleteOrganization' do
          delete = Library::Organizations.new(session[:token], $cf_target).delete($config, params[:orgGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS
          end
        end

        app.post '/updateOrganization' do
          if params[:modified_name].size >= 4
            update =  Library::Organizations.new(session[:token], $cf_target).update(params[:modified_name], params[:current_organization])
          else
            redirect redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + '?error=The name is too short (min. 4 characters)'
          end

          if defined?(update.message)
            redirect redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{update.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end