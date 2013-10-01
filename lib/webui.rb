require 'yaml'
require 'config'
require 'dev_utils'
require 'date'
require 'profiler'
require 'color/css'
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

    get '/css' do

      design = YAML.load_file(File.expand_path('../../config/design.yml', __FILE__))

      content_type 'text/css', :charset => 'utf-8'

      erb :'design/site.css', {

      :locals =>
              {
                  :design => design
              }
      }
    end


    get '/design' do
      erb :'design/design_test.html', {:layout => :'layouts/user'}
    end

    get '/email' do
      erb :'guest_pages/email', :locals => { :link => 'http://www.google.com' }
    end

    get '/monitoring' do

      report = params[:report] || 'half_of_day'

      report_data_cache_dir = File.expand_path('../../monitoring_cache', __FILE__)
      header_file = File.join(report_data_cache_dir, "#{report}.header")
      data_file = File.join(report_data_cache_dir, "#{report}.data")
      header_title = 'QoS Monitoring'

      unless File.exist?(header_file) && File.exist?(data_file)
        return  erb :'monitoring/monitoring_empty', :layout => :'monitoring/monitoring_layout',
                    :locals => {
                        :page_title => 'Monitoring',
                        :header_title => header_title
                    }
      end

      header = JSON.parse(File.read(header_file))
      body_content =  JSON.parse(File.read(data_file))

      erb :'monitoring/monitoring', :layout => :'monitoring/monitoring_layout',
          :locals => {
              :header => header,
              :body_content => body_content,
              :header_title => header_title,
              :page_title => 'Monitoring'
          }
    end
  end
end
