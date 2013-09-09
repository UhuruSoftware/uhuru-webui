require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Account
      def self.registered(app)

        app.get ACCOUNT do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          error_message = params[:message] if defined?(params[:message])

          erb :'user_pages/usersettings', {
              :layout => :'layouts/user',
              :locals => {
                  :error_message => error_message
              }
          }
        end

        app.post '/updateUserName' do
          if params[:first_name].size < 1
            redirect ACCOUNT + '?message=Please enter your first name'
          elsif params[:last_name].size < 1
            redirect ACCOUNT + '?message=Please enter your last name'
          end

          user_sign_up = UsersSetup.new($config)
          user = user_sign_up.update_user_info(session[:user_guid], params[:first_name], params[:last_name])
          session[:fname] = params[:first_name]

          if defined?(user.message)
            redirect ACCOUNT + "?message=#{user.info['error_description']}"
          else
            redirect ACCOUNT
          end
        end

        app.post '/updateUserPassword' do
          if params[:new_pass1].size < 8 || params[:new_pass2].size < 8
            redirect ACCOUNT + '?message=The password you have entered is to weak'
          elsif params[:new_pass1] != params[:new_pass2]
            redirect ACCOUNT + '?message=The password and confirm password are not the same'
          end

          user_sign_up = UsersSetup.new($config)
          password = user_sign_up.change_password(session[:user_guid], params[:new_pass1], params[:old_pass])

          if defined?(password.message)
            redirect ACCOUNT + "?message=#{password.info['error_description']}"
          else
            redirect ACCOUNT
          end
        end



        app.get CREATE_SUBSCRIPTION do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          product_id = ChargifyWrapper.get_product_by_handle($config[:quota_settings][:product_handle])

          users = UsersSetup.new($config)
          name = users.get_details(session[:user_guid])

          first_name = name["familyname"] != nil ? name["familyname"] : ""
          last_name = name["givenname"] != nil ? name["givenname"] : ""
          email = session[:username]

          org_guid = params[:org_guid]
          puts org_guid
          org = Library::Organizations.new(session[:token], $cf_target)
          billing_managers = org.read_billings($config, org_guid)
          billing_manager_guid = billing_managers[0].guid

          reference = "#{billing_manager_guid} #{org_guid}"
          org_name = session[:currentOrganization_Name]

          product_hosted_page = "https://#{$config[:quota_settings][:billing_provider_domain]}.#{$config[:quota_settings][:billing_provider]}.com/h/#{product_id}/subscriptions/new?first_name=#{first_name}&last_name=#{last_name}&email=#{email}&reference=#{reference}&organization=#{org_name}"

          redirect product_hosted_page
        end

        app.get SUBSCRIPTION_RESULT do

          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end
          org = Library::Organizations.new(session[:token], $cf_target)
          customer_reference = params[:ref]

          org_guid = customer_reference.last(36).to_s
          if (ChargifyWrapper.subscription_exists?(customer_reference))
            org.make_organization_billable(org_guid)
          end

          org_name = org.get_name(org_guid)

          erb :subscribe_result, {:locals => {:org_name => org_name, :org_guid => org_guid}, :layout => :layout_user}
        end

      end
    end
  end
end