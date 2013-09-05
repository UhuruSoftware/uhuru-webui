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
        :auth_method                      => String,
        :enable_tls                       => String
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
      }
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end
end