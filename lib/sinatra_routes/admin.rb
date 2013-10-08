require 'sinatra/base'
require "admin_settings"

module Uhuru::Webui
  module SinatraRoutes
    module Administration
      def self.registered(app)

        app.get ADMINISTRATION do
          require_admin

          erb :'admin/index', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'info'
              }
          }
        end

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

        app.get ADMINISTRATION_BILLING do
          require_admin

          erb :'admin/billing', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'billing',
                  :public_key => $admin[:stripe][:publishable_key],
                  :secret_key => $admin[:stripe][:secret_key]
              }
          }
        end

        app.post ADMINISTRATION_BILLING do
          require_admin

          $admin[:stripe][:publishable_key] = params[:public_key]
          $admin[:stripe][:secret_key] = params[:secret_key]
          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_BILLING
        end

        app.get ADMINISTRATION_EMAIL do
          require_admin

          erb :'admin/email', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'email',
                  :registration_email => $admin[:email][:registration_email],
                  :welcome_email => $admin[:email][:welcome_email]
              }
          }
        end

        app.post ADMINISTRATION_EMAIL do
          require_admin

          $admin[:email][:registration_email] = params[:registration_email]
          $admin[:email][:welcome_email] = params[:welcome_email]
          Uhuru::Webui::AdminSettings.save_changed_value()

          redirect ADMINISTRATION_EMAIL
        end

      end
    end
  end
end