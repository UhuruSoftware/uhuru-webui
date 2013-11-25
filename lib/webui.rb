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
require 'pg'
require 'date'
require 'csv'

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
require 'billing/provider'
require 'reports'

module Uhuru::Webui
  # The main class for the website
  class Webui < Sinatra::Base

    ENV_COPY  = %w[ REQUEST_METHOD HTTP_COOKIE rack.request.cookie_string
                rack.session rack.session.options rack.input SERVER_SOFTWARE SERVER_NAME
                rack.version rack.errors rack.multithread rack.run_once SERVER_PORT SERVER_PROTOCOL
                rack.url_scheme REMOTE_ADDR sinatra.commaonlogger rack.logger ]

    set :root, File.expand_path("../../", __FILE__)
    set :views, File.expand_path("../../views", __FILE__)
    set :public_folder, File.expand_path("../../public", __FILE__)
    helpers Rack::Recaptcha::Helpers

    use Rack::Session::Pool

    # register all the necessary classes
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

      #add owner role to cloud controller admin for sys-org and monitoring organizations
      begin
        users = UsersSetup.new($config)
        uaa_users = users.uaa_get_users

        admin = uaa_users.select {|user| user[:is_admin] == true && user[:email] != "services"}.first
        admin_guid = admin[:id]

        admin_token = users.get_admin_token

        org = Library::Organizations.new(admin_token, $cf_target)
        monitoring_org = org.get_organization_by_name("monitoring")
        sys_org = org.get_organization_by_name("sys-org")

        cf_users = Library::Users.new(admin_token, $cf_target)
        cf_users.add_user_to_org_with_role(sys_org.guid, admin_guid, ["owner"])
        cf_users.add_user_to_org_with_role(monitoring_org.guid, admin_guid, ["owner"])
      rescue => ex
        $logger.error("Error while trying to add Owner role to the cloud controller admin for sys-org and monitoring - #{ex.message}:#{ex.backtrace}")
      end

      super()
    end

    # a switch function for the query strings to be passed directly
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

    # switch for get methods
    def switch_to_get(uri)
      switch_to uri, "GET"
    end

    # switch for get methods
    def switch_to_post(uri)
      switch_to uri, "POST"
    end

    # a method that verify if the user is loggedin
    # this action is called in each get and post methods for verification
    def require_login
      begin
        Library::Organizations.new(session[:token], $cf_target).read_all(session[:user_guid])
      rescue CFoundry::InvalidAuthToken
        return redirect SinatraRoutes::TOKEN_EXPIRED
      end

      unless session[:logged_in]
        redirect SinatraRoutes::LOGIN
      end
    end

    # verify if the user is loggedin and also if it is an admin user(similar to the require_login method)
    def require_admin
      if session[:logged_in] == false || session[:logged_in] == nil || session[:is_admin] == false || session[:is_admin] == nil
        redirect SinatraRoutes::LOGIN
      end
    end

    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    # a rescue method for the default not_found error page
    not_found do
      erb :'errors/error404', {:layout => :'layouts/layout_error'}
    end

    # a rescue method for all server error page types
    error do
      $logger.error("An error occurred (#{env['sinatra.error'].class}): #{env['sinatra.error'].message} - #{env['sinatra.error'].backtrace} ")

      erb :'errors/error500', {
          :layout => :'layouts/layout_error',
          :locals =>
              {
                  :error => "#{request.env['sinatra_routes.error'].to_s}"
              }
      }
    end

    # a method design to fetch the design.yml file for the web layout
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

    # Get method for the monitoring page
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