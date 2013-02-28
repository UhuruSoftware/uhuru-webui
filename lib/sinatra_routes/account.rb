require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Account
      def self.registered(app)

        app.get ACCOUNT do

          if session[:login_] == false
            redirect INDEX
          end

          erb :'user_pages/usersettings', {:layout => :'layouts/user'}
        end

        app.post '/updateUserName' do
          user_sign_up = UsersSetup.new(@config)
          user_sign_up.update_user_info(session[:user_guid], params[:first_name], params[:last_name])
          session[:fname] = params[:first_name]

          redirect ACCOUNT
        end

        app.post '/updateUserPassword' do
          user_sign_up = UsersSetup.new(@config)
          user_sign_up.change_password(session[:user_guid], params[:new_pass1], params[:old_pass])

          redirect ACCOUNT
        end



        app.get '/create_subscription' do

          product_id = "3283746"
          billing_manager_guid = "58f6e4e9-e4f2-47bb-b8b5-a1629457992d"

          users = UsersSetup.new(@config)
          name = users.get_details(session[:user_guid])

          first_name = "Marius"
          last_name = "Test"
          email = session[:username]


          org_guid = session[:currentOrganization]
          reference = "#{billing_manager_guid} #{org_guid}"
          org_name = session[:currentOrganization_Name]

          product_id = "3288276"
          product_hosted_page = "https://#{@config[:quota_settings][:billing_provider_domain]}.#{@config[:quota_settings][:billing_provider]}.com/h/#{product_id}/subscriptions/new?first_name=#{first_name}&last_name=#{last_name}&email=#{email}&reference=#{reference}&organization=#{org_name}"

          redirect product_hosted_page
        end

        app.get '/subscribe_result' do
          customer_reference = params[:ref]

          # credit_card_masked_number = "XXXX-XXXX-XXXX-1" and credit_card_type = "bogus" while chargify account is in test
          # is not known what the other credit card types are. For credit card masked number suppose the group after last -
          # which now is 1 will represent last four number from a real credit card.

          # this is only an example how to read credit card info for an organizations, having organization guid and billing manager guid
          # first parameter is organization guid and the second parameter is the billing manager guid which can be only one

          #credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(org_gui, billing_manager_guid)


          # this is only to see how make_organization_billable works, to be moved in the right place
          org_guid = customer_reference.last(36).to_s
          if (ChargifyWrapper.subscription_exists?(customer_reference))
            org = Organizations.new(session[:token], @cf_target)
            org.make_organization_billable(org_guid)
          end


          #org_guid = "2cfeb438-e804-4303-8637-476d7cdd6889" #session[:currentOrganization]
          org_name = org.get_name(org_guid)

          erb :subscribe_result, {:locals => {:org_name => org_name, :org_guid => org_guid}, :layout => :layout_user}
        end

      end
    end
  end
end