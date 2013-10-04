require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Account
      def self.registered(app)

        app.get ACCOUNT do
          require_login

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

      end
    end
  end
end