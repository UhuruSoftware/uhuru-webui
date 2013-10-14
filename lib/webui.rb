require 'yaml'
require 'date'
require 'profiler'
require 'color/css'
require 'regex'
require 'net/smtp'
require 'openssl'
require "email"
require "encryption"
require 'rack/recaptcha'
require 'uri'
require 'base32'


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
require 'sinatra_routes/cloud_feedback'
require 'sinatra_routes/admin'

require 'organizations'
require 'spaces'
require 'users'
require 'applications'
require 'service_instances'
require 'users_setup'
require 'readapps'
require 'domains'
require 'routes'
require 'dev_utils'

require 'billing/provider'



module Uhuru::Webui
  class Webui < Sinatra::Base

    ENV_COPY  = %w[ REQUEST_METHOD HTTP_COOKIE rack.request.cookie_string
                rack.session rack.session.options rack.input]

    set :root, File.expand_path("../../", __FILE__)
    set :views, File.expand_path("../../views", __FILE__)
    set :public_folder, File.expand_path("../../public", __FILE__)
    helpers Rack::Recaptcha::Helpers

    use Rack::Session::Pool

    register Uhuru::Webui::SinatraRoutes::Guest
    register Uhuru::Webui::SinatraRoutes::Account
    register Uhuru::Webui::SinatraRoutes::Organizations
    register Uhuru::Webui::SinatraRoutes::Spaces
    register Uhuru::Webui::SinatraRoutes::Apps
    register Uhuru::Webui::SinatraRoutes::Services
    register Uhuru::Webui::SinatraRoutes::Users
    register Uhuru::Webui::SinatraRoutes::Domains
    register Uhuru::Webui::SinatraRoutes::Routes
    register Uhuru::Webui::SinatraRoutes::CloudFeedback
    register Uhuru::Webui::SinatraRoutes::Administration

    def initialize()
      $cf_target = $config[:cloud_controller_url]
      super()
    end

    def switch_to(uri, method)

      uri_info = URI.parse(URI.escape(uri))

      new_env = env.slice(*ENV_COPY).merge({
                                               "PATH_INFO"    => uri_info.path,
                                               "QUERY_STRING"    => uri_info.query,
                                               "HTTP_REFERER" => env["REQUEST_URI"],
                                               "REQUEST_METHOD" => method
                                           })
      new_env.merge!(headers) if headers
      call( new_env ).last.join
    end

    def switch_to_get(uri)
      switch_to uri, "GET"
    end

    def switch_to_post(uri)
      switch_to uri, "POST"
    end


    def require_login
      if  CFoundry::V2::Client.new($cf_target, session[:token]).token == nil
        redirect SinatraRoutes::LOGIN + "?error=Session has expired, please login again."
      end

      unless session[:logged_in]
        redirect SinatraRoutes::LOGIN
      end
    end

    def require_admin
      if session[:logged_in] == false || session[:logged_in] == nil || session[:is_admin] == false
        redirect SinatraRoutes::INDEX
      end
    end

    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    not_found do
      erb :'errors/error404', {:layout => :'layouts/layout_error'}
    end

    error do
      $logger.error("An error occurred: #{env['sinatra.error'].message} - #{env['sinatra.error'].backtrace} ")

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