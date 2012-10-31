require 'lib/organizations'
require 'lib/spaces'
require 'lib/users'
require 'lib/applications'
require 'lib/service_instances'
require 'lib/users_setup'
require 'lib/readapps'
require 'logger'

class UhuruConfig
  DEFAULT_CONFIG_PATH = File.expand_path("../config/uhuru-webui.yml", __FILE__)

  def self.load
    config = YAML.load_file(DEFAULT_CONFIG_PATH)

    @cloud_controller_api = config["cloudfoundry"]["cloud-controller-api"]
    @client_id = config["cloudfoundry"]["client-id"]
    @client_secret = config["cloudfoundry"]["client-secret"]
    @uaa_api = config["uaa"]["uaa-api"]
    @uaac_path = config["uaa"]["uaac-path"]
    @uhuru_webui_port = config["uhuru"]["webui-port"]
    @dev_mode = config["uhuru"]["dev-mode"]
    @logger = self.set_logger(config["logger"]["path"])
  end

  def self.cloud_controller_api
    @cloud_controller_api
  end

  def self.client_id
    @client_id
  end

  def self.client_secret
    @client_secret
  end

  def self.uaa_api
    @uaa_api
  end

  def self.uhuru_webui_port
    @uhuru_webui_port
  end

  def self.dev_mode
    @dev_mode
  end

  def self.logger
    @logger
  end

  def self.set_logger(logger_path)
    logger_file =  File.join(File.dirname(__FILE__), logger_path)
    logger = Logger.new(logger_file)
    logger.datetime_format = "%Y-%m-%d %H:%M:%S"

    if (!@dev_mode)
      logger.level = Logger::WARN
    end

    logger
  end

end