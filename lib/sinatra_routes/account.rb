#
#   NOTE: This is the settings page from a LoggedIn.
#
module Uhuru::Webui
  module SinatraRoutes
    module Account
      def self.registered(app)

        # Get method for the account page
        app.get ACCOUNT do
          require_login

          message = params[:message]
          error_message = message if defined?(message)

          erb :'user_pages/usersettings', {
              :layout => :'layouts/user',
              :locals => {
                  :error_message => error_message,
                  :last_name => session[:last_name],
                  :first_name => session[:first_name]
              }
          }
        end

        # Post method for update user first name and last name
        app.post '/updateUserName' do
          require_login

          first_name = params[:first_name]
          last_name = params[:last_name]

          if first_name.size < 1
            return switch_to_get ACCOUNT + '?message=Please enter your first name'
          elsif last_name.size < 1
            return switch_to_get ACCOUNT + '?message=Please enter your last name'
          end

          user_setup = UsersSetup.new($config)
          user = user_setup.update_user_info(session[:user_guid], first_name, last_name)
          session[:first_name] = first_name
          session[:last_name] = last_name

          if defined?(user.message)
            switch_to_get ACCOUNT + "?message=#{user.info['error_description']}"
          else
            switch_to_get ACCOUNT
          end
        end

        # Post method for changing the password
        app.post '/updateUserPassword' do
          require_login

          password = params[:new_pass1]
          confirm_password = params[:new_pass2]
          old_password = params[:old_pass]

          if password.size < 8 || confirm_password.size < 8
            return switch_to_get ACCOUNT + '?message=The password you have entered is to weak'
          elsif password != confirm_password
            return switch_to_get ACCOUNT + "?message=The password and its confirmation don't match"
          end

          user_setup = UsersSetup.new($config)
          begin
            user_setup.change_password(session[:user_guid], password, old_password)
            return switch_to_get ACCOUNT
          rescue CF::UAA::TargetError => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            return switch_to_get ACCOUNT + "?message=#{ex.info['error_description']}"
          end
        end
      end
    end
  end
end