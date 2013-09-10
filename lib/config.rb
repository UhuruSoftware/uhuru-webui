require 'organizations'
require 'spaces'
require 'users'
require 'applications'
require 'service_instances'
require 'users_setup'
require 'readapps'
require 'logger'
require 'credit_cards'
require 'domains'
require 'routes'
require 'vcap/config'
require 'regex'
require 'net/smtp'
require 'openssl'
require "email"
require "enc"
require 'rack/recaptcha'
require 'uri'
require 'base32'
require 'chargify_wrapper'
require 'billing_helper'
require 'http_direct_client'

module Uhuru
  module Webui
  end
end

class Uhuru::Webui::Config < VCAP::Config
  DEFAULT_CONFIG_PATH = File.expand_path('../../uhuru-webui.yml', __FILE__)

  define_schema do
    {

      :webui =>{
        :page_title                       => String,
        :site_tab                         => String,
        :welcome_message                  => String,
        :copyright_message                => String,
        #:color_theme                     => String,

        :domain                           => String,
        :activation_link_secret           => String,
        :more_videos_link                 => String,
        :guest_feedback_link              => String,
        :twitter_link                     => String,
        :facebook_link                    => String,
        :terms_of_services_link           => String,
        :privacy_policy_link              => String,
        :visual_studio_plugin_link        => String,
        :app_cloud_admin_link             => String,
        :command_line_link                => String,
        :eclipse_url                      => String
      },

      :cloud_controller_url               => String,

      :uaa => {
        :url                              => String,
        :client_id                        => String,
        :client_secret                    => String
      },

      :contact => {
        :company                          => String,
        :address                          => String,
        :phone                            => String,
        :email                            => String
      },

      :email => {
        :from                             => String,
        :from_alias                       => String,
        :server                           => String,
        :port                             => Integer,
        :user                             => String,
        :secret                           => String,
        :auth_method                      => Symbol,
        :enable_tls                       => TrueClass
      },

      :recaptcha => {
        :recaptcha_private_key            => String,
        :recaptcha_public_key             => String
      },

      :quota_settings => {
          :billing_provider               => String,
          :billing_provider_domain        => String,
          :auth_token                     => String,
          :product_handle                 => String,
          :division_factor                => Integer
      },

      :monitoring => {
          :reports => {
             :half_of_day => {
                  :resolution             =>Integer,
                  :resolution_unit        =>String,
                  :sample_count           =>Integer
             },
             :last_day => {
                 :resolution              =>Integer,
                 :resolution_unit         =>String,
                 :sample_count            =>Integer
             },
             :last_week => {
                  :resolution             =>Integer,
                  :resolution_unit        =>String,
                  :sample_count           =>Integer
              },
             :last_month => {
                  :resolution             =>Integer,
                  :resolution_unit        =>String,
                  :sample_count           =>Integer
              },
             :last_year => {
                 :resolution              =>Integer,
                 :resolution_unit         =>String,
                 :sample_count            =>Integer
             }
          },
          :vmc_executable_path            =>String,
          :cloud_user                     =>String,
          :cloud_password                 =>String,
          :default_org                    =>String,
          :default_space                  =>String,
          :apps_domain                    =>Array,
          :email_to                       =>String,
          :sleep_after_app_push           =>Integer,
          :pause_after_each_app           =>Integer,
          :database => {
            :database                     =>String,
            :host                         =>String,
            :port                         =>Integer,
            :encoding                     =>String,
            :username                     =>String,
            optional(:password)           =>String,
            :adapter                      =>String,
            :timeout                      =>Integer,
          },
          :components => {
          :deas                           =>Array,
          :services                       =>Array,
          },
          :buildpacks => {
            :dotNet                       =>String,
            :java                         =>String,
            :nodejs                       =>String,
            :php                          =>String,
            :ruby                         =>String
          }
      }

    #components:
    #       deas:
    #        - name: "dea"
    #    - name: "win_dea"
    #   services:
    #        - name: mysql_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: mongodb_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: redis_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: redis_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: rabbit_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: postgresql_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: uhuru_tunnel_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: uhurufs_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #    - name: mssql_node
    #      token: ec9743a4-6587-4356-8b9e-72d66b36a7f4
    #buildpacks:
    #    dotNet: https://github.com/stefanschneider/dummy-buildpack.git
    #java: https://github.com/cloudfoundry/java-buildpack
    #nodejs: https://github.com/cloudfoundry/heroku-buildpack-nodejs
    #php: https://github.com/heroku/heroku-buildpack-php
    #ruby: https://github.com/cloudfoundry/heroku-buildpack-ruby
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end
end
