require 'organizations'
require 'spaces'
require 'users'
require 'applications'
require 'service_instances'
require 'users_setup'
require 'readapps'
require 'logger'
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

module Uhuru
  module Webui
  end
end

class Uhuru::Webui::Config < VCAP::Config
  DEFAULT_CONFIG_PATH = File.expand_path('../../uhuru-webui.yml', __FILE__)

  define_schema do
    {

      :cloud_controller_url               => String,
      :message_bus_uri                    => String,
      :dev_mode                           => Object,
      :bind_address                       => String,
      :uaa => {
        :url                              => String,
        :client_id                        => String,
        :client_secret                    => String
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
            :ruby                         =>String,
          }
      },
      :admin_config_file                  =>String
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end
end
