require 'yaml'
require 'config'
require 'dev_utils'
require 'date'
require 'profiler'
require 'sinatra/session'
require 'sinatra/base'
require 'sinatra_routes/route_definitions'
require 'sinatra_routes/guest'
require 'sinatra_routes/login'
require 'sinatra_routes/account'
require 'sinatra_routes/organizations'
require 'sinatra_routes/organization'
require 'sinatra_routes/spaces'
require 'sinatra_routes/apps'
require 'sinatra_routes/services'

module Uhuru::Webui
  class Webui < Sinatra::Base
    set :root, File.expand_path("../../", __FILE__)
    set :views, File.expand_path("../../views", __FILE__)
    set :public_folder, File.expand_path("../../public", __FILE__)
    set :session_fail, '/login'
    set :session_secret, 'secret!'
    set :sessions, true
    helpers Rack::Recaptcha::Helpers
    enable :sessions
    recaptcha = YAML::load(File.open('../config/uhuru-webui.yml'))
    use Rack::Logger
    use Rack::Recaptcha, :public_key => recaptcha["recaptcha"]["recaptcha_public_key"], :private_key => recaptcha["recaptcha"]["recaptcha_private_key"]


    register Uhuru::Webui::SinatraRoutes::Guest
    register Uhuru::Webui::SinatraRoutes::Login
    register Uhuru::Webui::SinatraRoutes::Account
    register Uhuru::Webui::SinatraRoutes::Organizations
    register Uhuru::Webui::SinatraRoutes::Organization
    register Uhuru::Webui::SinatraRoutes::Spaces
    register Uhuru::Webui::SinatraRoutes::Apps
    register Uhuru::Webui::SinatraRoutes::Services


    def initialize(config)
      @config = config
      $config = config
      @cf_target = @config[:cloudfoundry][:cloud_controller_api]
      $cf_target = @config[:cloudfoundry][:cloud_controller_api]
      # this is a variable witch holds the / symbol to be rendered afterwards in css, it is used at breadcrumb navigation
      $slash = '<span class="breadcrumb_slash"> / </span>'

        #use Rack::Recaptcha, :public_key => $config[:recaptcha][:recaptcha_public_key], :private_key => $config[:recaptcha][:recaptcha_private_key]

      # this is the time variable witch will be passed at every page at the bottom
      @time = Time.now
      $this_time = @time.strftime("%m/%d/%Y")
      $path_home = ""

      ChargifyWrapper.configure(config)
      BillingHelper.initialize(config)

      super()

      configure_sinatra
    end

    def configure_sinatra

    end

    #set :dump_errors, true
    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    error 404 do
      @timeNow = $this_time
      erb :'errors/error404', {:layout => :'layouts/layout_error'}
    end

    error do
      session[:error] = "#{request.env['sinatra_routes.error'].to_s}"
      erb :'errors/error500', {:layout => :'layouts/layout_error'}
    end
  end
end