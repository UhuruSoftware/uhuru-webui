require 'organizations'
require 'spaces'
require 'users'
require 'applications'
require 'service_instances'
require 'users_setup'
require 'readapps'
require 'logger'
require 'credit_cards'
require 'domains_api'
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
          :activation_link_secret           => String,
          :signup_user_password             => String,
          :activation_link_secret           => String,
          :signup_user_password             => String,
          :company_link                     => String,
          :support_link                     => String,
          :more_videos_link                 => String,
          :guest_feedback_link              => String,
          :twitter_link                     => String,
          :facebook_link                    => String,
          :terms_of_services_link           => String,
          :privacy_policy_link              => String,
          :support_link                     => String
      },

      :cloudfoundry => {
        :cloud_controller_api               => String,
        :client_id                          => String,
        :client_secret                      => String,
        :cloud_controller_admin             => String,
        :cloud_controller_pass              => String
      },

      :default_domain => {
        :page_title                         => String,
        :welcome_message                    => String
      },

      :uaa => {
        :uaa_api                            => String
      },

      :contact => {
        :company                            => String,
        :address                            => String,
        :phone                              => String,
        :email                              => String
      },

      :email => {
        :smtp_link_1                        => String,
        :smtp_link_2                        => String,
        :from_title                         => String,
        :from                               => String,
        :subject                            => String
      },

      :recaptcha => {
        :recaptcha_private_key              => String,
        :recaptcha_public_key               => String
      },

      :quota_settings => {
          :billing_provider                 => String,
          :billing_provider_domain          => String,
          :auth_token                       => String,
          :product_handle                   => String,
          :division_factor                  => Integer
      }
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end
end