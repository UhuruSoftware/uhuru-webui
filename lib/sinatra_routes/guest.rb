require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Guest
      def self.registered(app)

        app.get INDEX do
          session[:login_] = false

          welcome_message = nil
          page_title = nil
          $site_tab = nil

          $config[:domains].each do |domain|
            if request.env['HTTP_HOST'].to_s == domain['url']
              welcome_message = domain['welcome_message']
              page_title = domain['page_title']
              $site_tab = domain['site_tab']
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
              $site_tab = $config[:default_domain][:site_tab]
            end
          end

          erb :'guest_pages/index',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message
                  }
              }
        end

        app.get LOGIN do
          welcome_message = nil
          page_title = nil
          $config[:domains].each do |domain|
            if request.env['HTTP_HOST'].to_s == domain['url']
              welcome_message = domain['welcome_message']
              page_title = domain['page_title']
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
            end
          end

          if params[:error] != nil && params[:error] != ''
            error_message = $errors['login_error']
            error_username = params[:username]
          else
            error_message = ''
            error_username = ''
          end

          erb :'guest_pages/login',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message,
                      :error => error_message,
                      :error_username => error_username,
                      :include_erb => :'user_pages/login'
                  }
              }
        end

        app.get SIGNUP do
          welcome_message = nil
          page_title = nil
          $config[:domains].each do |domain|
            if request.env['HTTP_HOST'].to_s == domain['url']
              welcome_message = domain['welcome_message']
              page_title = domain['page_title']
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
            end
          end

          if params[:error] != nil && params[:error] != ''
            error_username = params[:username]
            error_first_name = params[:first_name]
            error_last_name = params[:last_name]

            if params[:message] == 'email_format'
              error_message = $errors['signup_error_email_format']
            elsif params[:message] == 'first_name'
              error_message = $errors['signup_error_first_name']
            elsif params[:message] == 'last_name'
              error_message = $errors['signup_error_last_name']
            elsif params[:message] == 'password_size'
              error_message = $errors['signup_error_password_size']
            elsif params[:message] == 'password_difference'
              error_message = $errors['signup_error_password_difference']
            elsif params[:error] == 'server_error'
              error_message = $errors['signup_server_error']
            elsif params[:error] == 'user_exists'
              error_message = $errors['signup_user_exists_error']
            else
              error_message = $errors['signup_create_organization_error']
            end
          else
            error_message = ''
            error_username = ''
            error_first_name = ''
            error_last_name = ''
          end

          erb :'guest_pages/signup',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message,
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

            if user != 'error'
              session[:token] = user.token
              session[:login_] = true

              session[:fname] = user.first_name
              session[:lname] = user.last_name
              session[:username] = params[:username]
              session[:user_guid] = user.guid
              session[:secret] = session[:session_id]

              redirect ORGANIZATIONS
            else
              redirect LOGIN + "?error=login_error&username=#{params[:username]}"
            end
          else
            redirect LOGIN
          end
        end

        app.post SIGNUP do
          key = $config[:webui][:activation_link_secret]

          if /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(params[:email])
            email = Encryption.encrypt_text(params[:email], key)
          else
            redirect SIGNUP + "?error=server_error&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=email_format"
          end

          if params[:first_name].size >= 1
            family_name = Encryption.encrypt_text(params[:first_name], key)
          else
            redirect SIGNUP + "?error=server_error&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=first_name"
          end
          if params[:last_name].size >= 1
            given_name = Encryption.encrypt_text(params[:last_name], key)
          else
            redirect SIGNUP + "?error=server_error&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=last_name"
          end

          if params[:password].size >= 8
            if params[:password] == params[:confirm_password]
              pass = Encryption.encrypt_text(params[:password], key)
            else
              redirect SIGNUP + "?error=server_error&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=password_difference"
            end
          else
            redirect SIGNUP + "?error=server_error&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=password_size"
          end

          user_sign_up = UsersSetup.new($config)
          user = user_sign_up.signup(params[:email], $config[:webui][:signup_user_password], params[:last_name], params[:first_name])

          if user != 'error' && user != 'user exists' && user != 'org create error'

            link = "http://#{request.env['HTTP_HOST'].to_s}/activate/#{URI.encode(Base32.encode(pass))}/#{URI.encode(Base32.encode(user.guid))}"
            Email::send_email(params[:email], erb(:'guest_pages/email', {:locals =>{:link => link}}))

            ##if recaptcha_valid? then

              #TODO:   --   MAKE RECAPTCH ERRORS

            ##end

            session[:token] = user.token
            session[:fname] = user.first_name
            session[:lname] = user.last_name
            session[:username] = params[:username]
            session[:user_guid] = user.guid
            session[:secret] = session[:session_id]
            session[:login_] = true

            redirect PLEASE_CONFIRM
          else
            if user == 'error'
              redirect SIGNUP + "?error=server_error&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}"
            elsif user == 'user exists'
              redirect SIGNUP + "?error=user_exists&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}"
            else
              redirect SIGNUP + "?error=create_organization&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}"
            end
          end
        end



        app.get LOGOUT do
          redirect INDEX
        end



        app.get PLEASE_CONFIRM do
          session[:login_] = false

          welcome_message = nil
          page_title = nil
          $config[:domains].each do |domain|
            if request.env['HTTP_HOST'].to_s == domain['url']
              welcome_message = domain['welcome_message']
              page_title = domain['page_title']
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
            end
          end

          erb :'guest_pages/pleaseConfirm',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message
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

          welcome_message = nil
          page_title = nil
          $config[:domains].each do |domain|
            if request.env['HTTP_HOST'].to_s == domain['url']
              welcome_message = domain['welcome_message']
              page_title = domain['page_title']
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
            end
          end

          erb :'guest_pages/activated',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message
                  }
              }
        end

      end
    end
  end
end