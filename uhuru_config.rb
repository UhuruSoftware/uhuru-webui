require 'lib/organizations'
require 'lib/spaces'
require 'lib/users'
require 'lib/applications'
require 'lib/service_instances'

class UhuruConfig
  DEFAULT_CONFIG_PATH = File.expand_path("../config/uhuru-webui.yml", __FILE__)

  def self.load
    config = YAML.load_file(DEFAULT_CONFIG_PATH)

    @cloud_controller_api = config["cloudfoundry"]["cloud-controller-api"]
    @uhuru_webui_port = config["uhuru"]["webui-port"]
    @dev_mode = config["uhuru"]["dev-mode"]
  end

  def self.cloud_controller_api
    @cloud_controller_api
  end

  def self.uhuru_webui_port
    @uhuru_webui_port
  end

  def self.dev_mode
    @dev_mode
  end

end