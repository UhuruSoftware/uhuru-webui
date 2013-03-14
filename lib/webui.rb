require 'yaml'
require 'config'
require 'dev_utils'
require 'date'
require 'profiler'
require 'sinatra/session'
require 'sinatra/base'
require 'sinatra_routes/route_definitions'
require 'sinatra_routes/guest'
require 'sinatra_routes/account'
require 'sinatra_routes/organizations'
require 'sinatra_routes/spaces'
require 'sinatra_routes/apps'
require 'sinatra_routes/services'
require 'sinatra_routes/users'
require 'sinatra_routes/domains'
require 'sinatra_routes/routes'

module Uhuru::Webui
  class Webui < Sinatra::Base

    set :root, File.expand_path("../../", __FILE__)
    set :views, File.expand_path("../../views", __FILE__)
    set :public_folder, File.expand_path("../../public", __FILE__)
    set :session_fail, '/login'
    set :session_secret, 'secret!'
    set :sessions, true

    helpers Rack::Recaptcha::Helpers

    use Rack::Logger

    register Uhuru::Webui::SinatraRoutes::Guest
    register Uhuru::Webui::SinatraRoutes::Account
    register Uhuru::Webui::SinatraRoutes::Organizations
    register Uhuru::Webui::SinatraRoutes::Spaces
    register Uhuru::Webui::SinatraRoutes::Apps
    register Uhuru::Webui::SinatraRoutes::Services
    register Uhuru::Webui::SinatraRoutes::Users
    register Uhuru::Webui::SinatraRoutes::Domains
    register Uhuru::Webui::SinatraRoutes::Routes

    def initialize(config)
      $config = config
      $cf_target = $config[:cloud_controller_url]
      $errors = YAML::load(File.open(File.expand_path("../../config/error_messages.yml", __FILE__)))

      ChargifyWrapper.configure(config)
      BillingHelper.initialize(config)

      super()
    end

    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    error 404 do
      erb :'errors/error404', {:layout => :'layouts/layout_error'}
    end

    error do
      erb :'errors/error500', {
          :layout => :'layouts/layout_error',
          :locals =>
              {
                  :error => "#{request.env['sinatra_routes.error'].to_s}"
              }
      }
    end

  end
end
