require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Guest
      def self.registered(app)

        app.get INDEX do
          session[:login_] = false
          $site_tab = $config[:webui][:site_tab]

          erb :'guest_pages/index',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                  }
              }
        end

        app.get LOGIN do
          error_message = params[:error] if defined?(params[:error])
          error_username = params[:username] if defined?(params[:username])

          erb :'guest_pages/login',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                      :error => error_message,
                      :error_username => error_username,
                      :include_erb => :'user_pages/login'
                  }
              }
        end

        app.get SIGNUP do
          error_username = params[:username] if defined?(params[:username])
          error_first_name = params[:first_name] if defined?(params[:firstname])
          error_last_name = params[:last_name] if defined?(params[:lastname])
          error_message = params[:message] if defined?(params[:message])

          erb :'guest_pages/signup',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                      :error_message => error_message,
                      :error_username => error_username,
                      :error_first_name => error_first_name,
                      :error_last_name => error_last_name,
                      :include_erb => :'user_pages/signup'
                  }
              }
        end



        app.post LOGIN do
          if params[:username]
            user_login = UsersSetup.new($config)
            user = user_login.login(params[:username], params[:password])

            unless defined?(user.message)
              session[:token] = user.token
              session[:login_] = true

              session[:fname] = user.first_name
              session[:lname] = user.last_name
              session[:username] = params[:username]
              session[:user_guid] = user.guid
              session[:secret] = session[:session_id]

              redirect ORGANIZATIONS
            else
              redirect LOGIN + "?error=#{user.message}&username=#{params[:username]}"
            end
          else
            redirect LOGIN
          end
        end

        app.post SIGNUP do
          unless recaptcha_valid?
            redirect SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Please type the correct code"
          end

          key = $config[:webui][:activation_link_secret]

          unless /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(params[:email])
            redirect SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Incorrect email format"
          end
          unless params[:first_name].size >= 1
            redirect SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Please enter your first name"
          end
          unless params[:last_name].size >= 1
            redirect SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Please enter your last name"
          end

          if params[:password].size >= 8
            if params[:password] == params[:confirm_password]
              pass = Encryption.encrypt_text(params[:password], key)
            else
              redirect SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Confirm the password correctly"
            end
          else
            redirect SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=The password is not strong enough"
          end

          user_sign_up = UsersSetup.new($config)
          user = user_sign_up.signup(params[:email], $config[:webui][:activation_link_secret], params[:last_name], params[:first_name])

          unless defined?(user.message)
            link = "http://#{request.env['HTTP_HOST'].to_s}/activate/#{URI.encode(Base32.encode(pass))}/#{URI.encode(Base32.encode(user.guid))}"
            Email::send_email(params[:email], 'Uhuru account confirmation', erb(:'guest_pages/email', {:locals =>{:link => link}}))

            session[:token] = user.token
            session[:fname] = user.first_name
            session[:lname] = user.last_name
            session[:username] = params[:username]
            session[:user_guid] = user.guid
            session[:secret] = session[:session_id]
            session[:login_] = true

            redirect PLEASE_CONFIRM
          else
            redirect SIGNUP + "?error=#{user.message}&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}"
          end
        end



        app.get LOGOUT do
          redirect INDEX
        end

        app.get PLEASE_CONFIRM do
          session[:login_] = false

          erb :'guest_pages/pleaseConfirm',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                  }
              }
        end

        app.get ACTIVATE_ACCOUNT do
          password_b32 = Base32.decode(params[:password])
          user_guid_b32 = Base32.decode(params[:guid])

          key = $config[:webui][:activation_link_secret]
          user_guid = Encryption.decrypt_text(user_guid_b32, key)
          password = Encryption.decrypt_text(password_b32, key)

          change_password = UsersSetup.new($config)
          change_password.change_password(user_guid_b32, password, $config[:webui][:signup_user_password])

          redirect ACTIVE
        end

        app.get ACTIVE do
          session[:login_] = false

          erb :'guest_pages/activated',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                  }
              }
        end
      end
    end
  end
end