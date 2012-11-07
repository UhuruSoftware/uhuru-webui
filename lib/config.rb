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

module Uhuru
  module Webui
  end
end

class Uhuru::Webui::Config < VCAP::Config
  DEFAULT_CONFIG_PATH = File.expand_path('../../uhuru-webui.yml', __FILE__)

  define_schema do
    {
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
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end
end