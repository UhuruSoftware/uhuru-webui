module Uhuru::Webui
  module SinatraRoutes
    module Guest
      def self.registered(app)
        app.get INDEX do
          session[:logged_in] = false

          erb :'guest_pages/index',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                  }
              }
        end

        app.get TOKEN_EXPIRED do
          switch_to_get "#{SinatraRoutes::LOGIN}?error=#Your token has expired, please login again."
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
                      :error_message => error_message,
                      :error_username => error_username,
                      :include_erb => :'guest_pages/login'
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
                      :include_erb => :'guest_pages/signup'
                  }
              }
        end

        app.post LOGIN do
          if params[:username]
            user_login = UsersSetup.new($config)

            begin
              user = user_login.login(params[:username], params[:password])
              session[:token] = user.token
              session[:logged_in] = true
              session[:fname] = user.first_name
              session[:lname] = user.last_name
              session[:username] = params[:username]
              session[:user_guid] = user.guid
              session[:is_admin] = user.is_admin

              redirect ORGANIZATIONS
            rescue CF::UAA::TargetError
              return switch_to_get LOGIN + "?error=Invalid Username or Password&username=#{params[:username]}"
            end
          else
            redirect LOGIN
          end
        end

        app.post SIGNUP do
          if $config[:recaptcha][:use_recaptcha] == true
            unless recaptcha_valid?
              return switch_to_get SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Human validation failed - please type the correct code"
            end
          end

          key = $config[:webui][:activation_link_secret]

          unless /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(params[:email])
            return switch_to_get SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Incorrect email format"
          end
          unless params[:first_name].size >= 1
            return switch_to_get SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Please enter your first name"
          end
          unless params[:last_name].size >= 1
            return switch_to_get SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Please enter your last name"
          end

          if params[:password].size >= 8
            if params[:password] == params[:confirm_password]
              pass = Encryption.encrypt_text(params[:password], key)
            else
              return switch_to_get SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=Confirm password is not correct"
            end
          else
            return switch_to_get SIGNUP + "?username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}&message=The password is not strong enough(min 8 characters)"
          end


          begin
            user_sign_up = UsersSetup.new($config)
            user = user_sign_up.signup(params[:email], $config[:webui][:activation_link_secret], params[:first_name], params[:last_name])
            user_guid = user.guid

            #verify if the user is invited by someone or it is a normal signup
            if session[:invitation_invited_by] == nil || session[:invitation_role] == nil || session[:invitation_org] == nil
              link = "http://#{request.env['HTTP_HOST'].to_s}/activate/#{URI.encode(Base32.encode(pass))}/#{URI.encode(Base32.encode(user.guid))}/#{params[:email]}"

              email_body = $config[:email][:registration_email]
              email_body.gsub!('#ACTIVATION_LINK#', link)
              email_body.gsub!('#FIRST_NAME#', params[:first_name])
              email_body.gsub!('#LAST_NAME#', params[:last_name])
              email_body.gsub!('#WEBSITE_URL#', "http://#{$config[:domain]}")

              Email::send_email(params[:email], 'Uhuru account confirmation', email_body)

              email_body.gsub!(link, '#ACTIVATION_LINK#')
              email_body.gsub!( params[:first_name], '#FIRST_NAME#')
              email_body.gsub!(params[:last_name], '#LAST_NAME#')
              email_body.gsub!( "http://#{$config[:domain]}", '#WEBSITE_URL#')

              redirect PLEASE_CONFIRM
            else
              begin
                #change the secret password
                user = UsersSetup.new($config)
                user.change_password(user_guid, params[:password], $config[:webui][:signup_user_password])

                #make an action (read orgs) with the user token in order to activate it user in the ccdb
                active_user = user.login(params[:email], params[:password])
                target = $config[:cloud_controller_url]
                CFoundry::V2::Client.new(target, active_user.token).organizations

                #make the invitation afther the user is active ...
                admin = UsersSetup.new($config)
                admin_token = admin.get_admin_token
                invite = Library::Users.new(admin_token, target)

                if session[:invitation_space] == nil || session[:invitation_space] == ""
                  invite.invite_user_with_role_to_org($config, params[:email], session[:invitation_org], session[:invitation_role])
                else
                  if !invite.any_org_roles?($config, session[:invitation_org], params[:email])
                    invite.invite_user_with_role_to_org($config, params[:email], session[:invitation_org], "auditor")
                  end
                  invite.invite_user_with_role_to_space($config, params[:email], session[:invitation_space], session[:invitation_role])
                end
              rescue Exception => e
                return switch_to_get SIGNUP + "?message=A an error occurred on your invitation from #{session[:invitation_invited_by]}."
              end

              session[:invitation_invited_email] = nil
              session[:invitation_invited_by] = nil
              session[:invitation_org] = nil
              session[:invitation_space] = nil
              session[:invitation_role] = nil

              redirect ACTIVE
            end
          rescue CF::UAA::TargetError => e
            return switch_to_get SIGNUP + "?message=#This username is already taken!&username=#{params[:email]}&first_name=#{params[:first_name]}&last_name=#{params[:last_name]}"
          end
        end

        app.get LOGOUT do
          redirect INDEX
        end

        app.get PLEASE_CONFIRM do
          session[:logged_in] = false

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

          user = UsersSetup.new($config)
          user.change_password(user_guid_b32, password, $config[:webui][:signup_user_password])
          user_detail = user.get_details(user_guid_b32)
          email_body = $config[:email][:welcome_email]

          email_body.gsub!('#FIRST_NAME#', user_detail["name"]["givenname"])
          email_body.gsub!('#LAST_NAME#', user_detail["name"]["familyname"])
          email_body.gsub!('#WEBSITE_URL#', "http://#{$config[:domain]}")

          Email::send_email(params[:email], 'Uhuru account confirmation', email_body)

          email_body.gsub!( user_detail["name"]["givenname"], '#FIRST_NAME#')
          email_body.gsub!(user_detail["name"]["familyname"], '#LAST_NAME#')
          email_body.gsub!("http://#{$config[:domain]}", '#WEBSITE_URL#')

          switch_to_get ACTIVE
        end

        app.get ACTIVE do
          session[:logged_in] = false

          erb :'guest_pages/activated',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                  }
              }
        end

        # the page that asks for the user email and forms a random password and sends it
        app.get FORGOT_PASSWORD do
          erb :'guest_pages/forgot_password',
              {
                  :layout => :'layouts/guest',
                  :locals => {
                      :page_title => $config[:webui][:page_title],
                      :welcome_message => $config[:webui][:welcome_message],
                  }
              }
        end

        app.post FORGOT_PASSWORD do
          random_password = (0..7).map { (65 + rand(26)).chr }.join
          user_id = UsersSetup.new($config).uaa_get_user_by_name(params[:email])

          link = "http://#{request.env['HTTP_HOST'].to_s}/reset_old_password/#{URI.encode(Base32.encode(user_id))}/#{URI.encode(Base32.encode(random_password))}"
          email_body = $config[:email][:password_recovery_email]
          email_body.gsub!('#FIRST_NAME#', params[:email])
          email_body.gsub!('#ACTIVATION_LINK#', link)
          email_body.gsub!('#PASSWORD#', random_password)

          Email::send_email(params[:email], 'Uhuru password recovery', email_body)

          email_body.gsub!(params[:email], '#FIRST_NAME#')
          email_body.gsub!(link, '#ACTIVATION_LINK#')
          email_body.gsub!(random_password, '#PASSWORD#')
          redirect PLEASE_CONFIRM
        end

        # apply the new password
        app.get RESET_OLD_PASSWORD do
          password = Base32.decode(params[:random_password])
          user_id = Base32.decode(params[:user_id])
          key = $config[:webui][:activation_link_secret]

          user = UsersSetup.new($config)
          user.recover_password(user_id, password)

          redirect LOGIN
        end


        # invite user
        app.get INVITE_USER do
          hashed_data = Base32.decode(params[:data])
          data = JSON.parse(hashed_data)

          session[:invitation_invited_email] = data['email']
          session[:invitation_invited_by] = data['invited_by']
          session[:invitation_role] = data['role']
          session[:invitation_org] = data['org']
          session[:invitation_space] = data['space']

          return switch_to_get SIGNUP
        end
      end
    end
  end
end