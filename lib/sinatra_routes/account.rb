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

      end
    end
  end
end