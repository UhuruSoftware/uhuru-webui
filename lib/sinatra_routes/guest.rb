require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Guest
      def self.registered(app)

        app.get INDEX do
          welcome_message = nil
          page_title = nil
          $config[:domains].each do |domain|
            if request.env["HTTP_HOST"].to_s == domain["url"]
              welcome_message = domain["welcome_message"]
              page_title = domain["page_title"]
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
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
            if request.env["HTTP_HOST"].to_s == domain["url"]
              welcome_message = domain["welcome_message"]
              page_title = domain["page_title"]
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
            end
          end

          erb :'guest_pages/login',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message,
                      :include_erb => :'user_pages/login'
                  }
              }
        end

        app.get SIGNUP do
          welcome_message = nil
          page_title = nil
          $config[:domains].each do |domain|
            if request.env["HTTP_HOST"].to_s == domain["url"]
              welcome_message = domain["welcome_message"]
              page_title = domain["page_title"]
            else
              page_title = $config[:default_domain][:page_title]
              welcome_message = $config[:default_domain][:welcome_message]
            end
          end

          erb :'guest_pages/signup',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => page_title,
                      :welcome_message => welcome_message,
                      :include_erb => :'user_pages/signup'
                  }
              }
        end

        app.post LOGIN do

          if params[:username]

            session[:temp_user_login] = params[:username]

            user_login = UsersSetup.new($config)
            user = user_login.login(params[:username], params[:password])

            session[:token] = user.token
            session[:login_] = true

            session[:fname] = user.first_name
            session[:lname] = user.last_name
            session[:username] = params[:username]
            session[:user_guid] = user.guid
            session[:secret] = session[:session_id]

            redirect ORGANIZATIONS
          else
            redirect LOGIN
          end
        end

        app.get LOGOUT do
          redirect INDEX
        end

        app.post SIGNUP do

          key = $config[:webui][:activation_link_secret]
          email = Encryption.encrypt_text(params[:email], key)
          pass = Encryption.encrypt_text(params[:password], key)
          family_name = Encryption.encrypt_text(params[:first_name], key)
          given_name = Encryption.encrypt_text(params[:last_name], key)

          user_sign_up = UsersSetup.new($config)
          user = user_sign_up.signup(params[:email], $config[:webui][:signup_user_password], params[:last_name], params[:first_name])

          link = "http://#{request.env["HTTP_HOST"].to_s}/activate/#{URI.encode(Base32.encode(pass))}/#{URI.encode(Base32.encode(user.guid))}"
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
        end

        app.get PLEASE_CONFIRM do

          erb :'guest_pages/pleaseConfirm',
              {
                  :layout => :'layouts/guest'
              }
        end

        app.get ACTIVATE_ACCOUNT do
          password_b32 = Base32.decode(params[:password])
          user_guid_b32 = Base32.decode(params[:email])

          key = $config[:webui][:activation_link_secret]
          user_guid = Encryption.decrypt_text(user_guid_b32, key)
          password = Encryption.decrypt_text(password_b32, key)

          change_password = UsersSetup.new(@config)
          change_password.change_password(user_guid, password, $config[:webui][:signup_user_password])

          redirect ACTIVE
        end

        app.get ACTIVE do

          erb :'guest_pages/activate',
              {
                  :layout => :'layouts/guest'
              }
        end

      end
    end
  end
end