#
#   NOTE: This is the admin page from a LoggedIn admin user.
#
require "admin_settings"

module Uhuru::Webui
  module SinatraRoutes
    module Administration
      def self.registered(app)

        # Get method for the administration page
        app.get ADMINISTRATION do
          require_admin

          erb :'admin/index', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'info'
              }
          }
        end

        # Get method for the settings tab
        app.get ADMINISTRATION_SETTINGS do
          require_admin

          erb :'admin/settings', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'settings',
                  :message => ''
              }
          }
        end

        # Post method for the settings tab
        app.post ADMINISTRATION_SETTINGS do
          require_admin
          message = ''

          if params.has_key? ("btn_export")
            send_file $config[:admin_config_file], :filename => "admin_settings.yml", :type => 'Application/octet-stream'
          elsif params.has_key? ("btn_import")
            if params.has_key?("file_input")
              tempfile = params['file_input'][:tempfile]
              settings = YAML.load_file(tempfile)
              if(settings)
                settings = VCAP.symbolize_keys(settings)
                new_settings = $admin.dup

                begin
                  Uhuru::Webui::AdminSettings.import_settings!(settings, new_settings)
                  Uhuru::Webui::AdminSettings.schema.validate(new_settings)
                  $admin = new_settings.dup
                  Uhuru::Webui::AdminSettings.save_changed_value
                  message = "Import successful!"
                rescue Membrane::SchemaValidationError => ex
                  $logger.error("#{ex.message}:#{ex.backtrace}")
                  message = "Error: #{ex.message}"
                end
              else
                message = "Could not parse yaml file"
              end

            else
              message = "No import file specified"
            end

            erb :'admin/settings', {
                :layout => :'layouts/admin',
                :locals => {
                    :current_tab => 'settings',
                    :message => message
                }
            }
          else
            redirect ADMINISTRATION_SETTINGS
          end
        end

        # Get method for the Web UI tab
        app.get ADMINISTRATION_WEBUI do
          require_admin

          erb :'admin/webui', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'webui',
                  :page_title => $admin[:webui][:page_title],
                  :site_tab => $admin[:webui][:site_tab],
                  :welcome_message => $admin[:webui][:welcome_message],
                  :copyright_message => $admin[:webui][:copyright_message],
                  :activation_link_secret => $admin[:webui][:activation_link_secret],
                  :more_videos_link => $admin[:webui][:more_videos_link],
                  :guest_feedback_link => $admin[:webui][:guest_feedback_link],
                  :twitter_link => $admin[:webui][:twitter_link],
                  :facebook_link => $admin[:webui][:facebook_link],
                  :terms_of_services_link => $admin[:webui][:terms_of_services_link],
                  :privacy_policy_link => $admin[:webui][:privacy_policy_link],
                  :visual_studio_plugin_link => $admin[:webui][:visual_studio_plugin_link],
                  :app_cloud_admin_link => $admin[:webui][:app_cloud_admin_link],
                  :command_line_link => $admin[:webui][:command_line_link],
                  :eclipse_url => $admin[:webui][:eclipse_url],
                  :company_link => $admin[:webui][:company_link],
                  :support_link => $admin[:webui][:support_link],
                  :start_page_text => $admin[:webui][:start_page_text],
                  :start_page_splash_text => $admin[:webui][:start_page_splash_text]
              }
          }
        end

        # Post method for the Web UI tab
        app.post ADMINISTRATION_WEBUI do
          require_admin

          $admin[:webui][:page_title] = params[:page_title]
          $admin[:webui][:site_tab] = params[:site_tab]
          $admin[:webui][:welcome_message] = params[:welcome_message]
          $admin[:webui][:copyright_message] = params[:copyright_message]
          $admin[:webui][:activation_link_secret] = params[:activation_link_secret]
          $admin[:webui][:more_videos_link] = params[:more_videos_link]
          $admin[:webui][:guest_feedback_link] = params[:guest_feedback_link]
          $admin[:webui][:twitter_link] = params[:twitter_link]
          $admin[:webui][:facebook_link] = params[:facebook_link]
          $admin[:webui][:terms_of_services_link] = params[:terms_of_services_link]
          $admin[:webui][:privacy_policy_link] = params[:privacy_policy_link]
          $admin[:webui][:visual_studio_plugin_link] = params[:visual_studio_plugin_link]
          $admin[:webui][:app_cloud_admin_link] = params[:app_cloud_admin_link]
          $admin[:webui][:command_line_link] = params[:command_line_link]
          $admin[:webui][:eclipse_url] = params[:eclipse_url]
          $admin[:webui][:company_link] = params[:company_link]
          $admin[:webui][:support_link] = params[:support_link]
          $admin[:webui][:start_page_text] = params[:start_page_text]
          $admin[:webui][:start_page_splash_text] = params[:start_page_splash_text]

          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_WEBUI
        end

        # Get method for the recaptcha tab
        app.get ADMINISTRATION_RECAPTCHA do
          require_admin

          erb :'admin/recaptcha', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'recaptcha',
                  :use_recaptcha => $admin[:recaptcha][:use_recaptcha],
                  :recaptcha_public_key => $admin[:recaptcha][:recaptcha_public_key],
                  :recaptcha_private_key => $admin[:recaptcha][:recaptcha_private_key]
              }
          }
        end

        # Post method for the recaptcha tab
        app.post ADMINISTRATION_RECAPTCHA do
          require_admin

          $admin[:recaptcha][:use_recaptcha] = params[:use_recaptcha]
          $admin[:recaptcha][:recaptcha_public_key] = params[:recaptcha_public_key]
          $admin[:recaptcha][:recaptcha_private_key] = params[:recaptcha_private_key]

          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_RECAPTCHA
        end

        # Get method for the contact tab
        app.get ADMINISTRATION_CONTACT do
          require_admin

          erb :'admin/contact', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'contact',
                  :company => $admin[:contact][:company],
                  :address => $admin[:contact][:address],
                  :phone => $admin[:contact][:phone],
                  :email => $admin[:contact][:email]
              }
          }
        end

        # Post method for the contact tab
        app.post ADMINISTRATION_CONTACT do
          require_admin

          $admin[:contact][:company] = params[:company]
          $admin[:contact][:address] = params[:address]
          $admin[:contact][:phone] = params[:phone]
          $admin[:contact][:email] = params[:email]
          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_CONTACT
        end

        # Get method for the billing tab
        app.get ADMINISTRATION_BILLING do
          require_admin

          erb :'admin/billing', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'billing'
              }
          }
        end

        # Post method for the billing tab
        app.post ADMINISTRATION_BILLING do
          require_admin

          $admin[:billing][:provider] = params[:provider]

          $admin[:billing][:options].each do |provider, values|
            values.each do |key, _|
              $admin[:billing][:options][provider][key] = params["#{provider}:#{key}"]
            end
          end

          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_BILLING
        end

        # Get method for the email tab
        app.get ADMINISTRATION_EMAIL do
          require_admin

          auth_method_items = {'Plain'=> 'plain', 'Login'=> 'login', 'CRAM-MD5'=> 'cram_md5'}

          erb :'admin/email', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'email',
                  :from => $admin[:email][:from],
                  :from_alias => $admin[:email][:from_alias],
                  :server => $admin[:email][:server],
                  :port => $admin[:email][:port],
                  :user => $admin[:email][:user],
                  :secret => $admin[:email][:secret],
                  :auth_method_items => auth_method_items,
                  :auth_method => $admin[:email][:auth_method],
                  :enable_tls => $admin[:email][:enable_tls],
                  :registration_email => $admin[:email][:registration_email],
                  :welcome_email => $admin[:email][:welcome_email],
                  :password_recovery_email => $admin[:email][:password_recovery_email]
              }
          }
        end

        # Post method for the email tab
        app.post ADMINISTRATION_EMAIL do
          require_admin

          from = params[:from]
          from_alias = params[:from_alias]
          port = params[:port]
          server = params[:server]
          user = params[:user]
          secret = params[:secret]
          auth_method = params[:auth_method]
          enable_tls = params[:enable_tls]

          $admin[:email][:from] = from
          $admin[:email][:from_alias] = from_alias
          $admin[:email][:server] = server
          $admin[:email][:port] = Integer(port)
          $admin[:email][:user] = user
          $admin[:email][:secret] = secret
          $admin[:email][:auth_method] = auth_method.to_sym
          if enable_tls
            $admin[:email][:enable_tls] = 'true'
          else
            $admin[:email][:enable_tls] = 'false'
          end
          $admin[:email][:registration_email] = params[:registration_email]
          $admin[:email][:welcome_email] = params[:welcome_email]
          $admin[:email][:password_recovery_email] = params[:password_recovery_email]
          Uhuru::Webui::AdminSettings.save_changed_value()

          redirect ADMINISTRATION_EMAIL
        end

        # Post method for the test email address form
        app.post ADMINISTRATION_EMAIL_TEST do
          require_admin

          test_email = params[:test_email]
          unless /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(test_email)
            return switch_to_get "#{ADMINISTRATION_EMAIL}?error=Please input a valid destination e-mail address"
          end

          email_server = server
          email_from =  from
          email_from_alias = from_alias
          email_port =  Integer(port)
          email_server_enable_tls = enable_tls
          email_server_user = user
          email_server_secret = secret
          email_server_auth_method = auth_method.to_sym


          client = Net::SMTP.new( email_server,email_port)

          if email_server_enable_tls
            context =   Net::SMTP.default_ssl_context
            client.enable_starttls(context)
          end

          begin

            msg = <<END_OF_MESSAGE
From: #{email_from_alias} <#{email_from}>
To: <#{test_email}>
Subject: Test email for Cloud Web UI
MIME-Version: 1.0
Content-type: text/html

Test email for Uhuru Cloud Web UI
END_OF_MESSAGE

            client.open_timeout = 10
            client.start(
                "localhost",
                email_server_user,
                email_server_secret,
                email_server_auth_method) do
              client.send_message msg, email_from, test_email

              switch_to_get "#{ADMINISTRATION_EMAIL}?message=Settings are working correctly."
            end
          rescue Exception => ex
            $logger.error("#{ex.message}:#{ex.backtrace}")
            switch_to_get "#{ADMINISTRATION_EMAIL}?error=Cannot connect to email server, please verify settings - #{ex.message}"
          end
        end

        # Get method for the reports tab
        app.get ADMINISTRATION_REPORTS do
          require_admin

          erb :'admin/reports', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'reports'
              }
          }
        end

        # Post method for the reports tab
        app.post ADMINISTRATION_REPORTS do
          require_admin

          query = params[:query]

          reports = Uhuru::Webui::CFReports.new
          reports.init_users

          begin
            data = reports.run_query(query)
          rescue => ex
            data = ex.message
          end

          erb :'admin/reports_view', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'reports',
                  :reports => reports,
                  :data => data,
                  :users_column => ["User", "Users"]
              }
          }
        end

        # Get method for the reports view
        app.get ADMINISTRATION_REPORTS_VIEW do
          require_admin

          reports = Uhuru::Webui::CFReports.new
          reports.init_users

          report = params[:report_name].to_sym

          data = reports.run_query(report)

          erb :'admin/reports_view', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'reports',
                  :reports => reports,
                  :data => data,
                  :users_column => $reports[:reports][report][:users_column]
              }
          }
        end

        # Get method for administration templates tab
        app.get ADMINISTRATION_TEMPLATES do
          require_admin

          erb :'admin/templates', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'templates'
              }
          }
        end

        # Get method for the users tab
        app.get ADMINISTRATION_USERS do
          require_admin

          erb :'admin/users', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'users',
                  :all_users => UsersSetup.new($config).uaa_get_users
              }
          }
        end

        # Post method for deleting a user from all users
        app.post ADMINISTRATION_USERS_DELETE do
          require_admin

          UsersSetup.new($config).delete_user(params[:user_id])

          redirect ADMINISTRATION_USERS
        end

        # Get method for logs tab
        app.get ADMINISTRATION_LOGS do
          require_admin

          log_file = $config[:logging][:file]
          json = File.read log_file
          logs = []

          Yajl::Parser.parse(json) { |obj|
            logs << obj
          }

          erb :'admin/logs', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'logs',
                  :original_size => logs.size,
                  :logs => logs.reverse[0..199]
              }
          }
        end
      end
    end
  end
end
