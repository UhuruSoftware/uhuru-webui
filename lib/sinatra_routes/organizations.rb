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

          months = []
          years = []

          current_month = Date.today.strftime("%m").to_i
          [{:name => 'January', :value => 1},
           {:name => 'February', :value => 2},
           {:name => 'March', :value => 3},
           {:name => 'April', :value => 4},
           {:name => 'May', :value => 6},
           {:name => 'June', :value => 6},
           {:name => 'July', :value => 7},
           {:name => 'August', :value => 8},
           {:name => 'September', :value => 9},
           {:name => 'October', :value => 10},
           {:name => 'November', :value => 11},
           {:name => 'December', :value => 12}].each do |month|
             if month[:value] >= current_month
               months.push(month)
             end
           end

          current_year = Date.today.strftime("%Y").to_i
          y = current_year
          #max credit card lifespan is in 20 - 25 years
          while y <= current_year + 30 do
            years.push(y)
            y += 1
          end

          list = File.open("../config/countries.txt", "rb").read
          countries = list.split(';')

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
            begin
              customer = Uhuru::Webui::Billing::Provider.provider.create_customer(session[:username], params[:stripeToken])
              Uhuru::Webui::Billing::Provider.provider.add_billing_binding(customer, create)
            rescue => e
              $logger.error("Error while trying to create an org for #{session[:user_guid]} - #{e.message}:#{e.backtrace}")
              Library::Organizations.new(session[:token], $cf_target).delete($config, create)
              redirect ORGANIZATIONS_CREATE + "?error=Could not setup your credit card information. Please contact support."
            end
          end
          redirect ORGANIZATIONS
        end


        app.post '/deleteOrganization' do
          require_login

          delete = Library::Organizations.new(session[:token], $cf_target).delete($config, params[:orgGuid])
          if defined?(delete.message)
            redirect ORGANIZATIONS + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS
          end
        end

        app.post '/updateOrganization' do
          require_login

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