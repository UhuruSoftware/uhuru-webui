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

        app.post ADMINISTRATION_CONTACT do
          require_admin

          $admin[:contact][:company] = params[:company]
          $admin[:contact][:address] = params[:address]
          $admin[:contact][:phone] = params[:phone]
          $admin[:contact][:email] = params[:email]
          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_CONTACT
        end

        app.get ADMINISTRATION_BILLING do
          require_admin

          erb :'admin/billing', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'billing',
                  #:public_key => $admin[:stripe][:publishable_key],
                  #:secret_key => $admin[:stripe][:secret_key]
              }
          }
        end

        app.post ADMINISTRATION_BILLING do
          require_admin

          #$admin[:stripe][:publishable_key] = params[:public_key]
          #$admin[:stripe][:secret_key] = params[:secret_key]
          Uhuru::Webui::AdminSettings.save_changed_value

          redirect ADMINISTRATION_BILLING
        end

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
                  :welcome_email => $admin[:email][:welcome_email]
              }
          }
        end

        app.post ADMINISTRATION_EMAIL do
          require_admin

          $admin[:email][:from] = params[:from]
          $admin[:email][:from_alias] = params[:from_alias]
          $admin[:email][:server] = params[:server]
          $admin[:email][:port] = Integer(params[:port])
          $admin[:email][:user] = params[:user]
          $admin[:email][:secret] = params[:secret]
          $admin[:email][:auth_method] = params[:auth_method].to_sym
          if params[:enable_tls]
            $admin[:email][:enable_tls] = 'true'
          else
            $admin[:email][:enable_tls] = 'false'
          end
          $admin[:email][:registration_email] = params[:registration_email]
          $admin[:email][:welcome_email] = params[:welcome_email]
          Uhuru::Webui::AdminSettings.save_changed_value()

          redirect ADMINISTRATION_EMAIL
        end


        app.get ADMINISTRATION_REPORTS do
          require_admin

          erb :'admin/reports', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'reports'
              }
          }
        end

      end
    end
  end
end