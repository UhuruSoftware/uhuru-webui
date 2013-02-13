require 'organizations'
require 'spaces'
require 'users'
require 'applications'
require 'service_instances'
require 'users_setup'
require 'readapps'
require 'logger'
require 'credit_cards'
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
          :activation_link_secret => String,
          :signup_user_password => String
      },

      :cloudfoundry => {
        :cloud_controller_api   => String,
        :client_id              => String,
        :client_secret          => String,
        :cloud_controller_admin => String,
        :cloud_controller_pass  => String
      },

      :uaa => {
        :uaa_api                => String,
      },

      :email => {
        :from => String,
        :from_alias => String,
        :server => String,
        :port => Integer,
        optional(:user) => String,
        optional(:secret) => String,
        optional(:auth_method) => Symbol,
        :enable_tls => bool
      },

      :recaptcha => {
        :recaptcha_private_key => String,
        :recaptcha_public_key => String\
      },

      :quota_settings => {
        :billing_provider => String,
        :billing_provider_domain => String,
        :auth_token => String,
        :division_factor => Integer
      }
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end
end