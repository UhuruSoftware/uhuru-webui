#!/usr/bin/env ruby

$:.unshift(File.expand_path("../../lib", __FILE__))
home = File.join(File.dirname(__FILE__), '/..')
ENV['BUNDLE_GEMFILE'] = "#{home}/Gemfile"
require "rubygems"
require "bundler/setup"
require "optparse"
require "time"

require 'vcap/config'

require 'admin_settings'
require 'json'
require 'securerandom'
require 'yaml'
require 'steno'
require 'benchmark'
require 'active_record'
require 'thread'
require 'net/http'
require 'config'
require 'users'
require 'email'
require "users_setup"
require "cfoundry"


APP_NAME_SUFFIX = '-monit-'

class String
  def from_human_readable_size
    if self.include? 'B'
      self.to_f
    elsif self.include? 'K'
      self.to_f * 1024
    elsif self.include? 'M'
      self.to_f * 1024 ** 2
    elsif self.include? 'G'
      self.to_f * 1024 ** 3
    elsif self.include? 'T'
      self.to_f * 1024 ** 4
    end
  end
end

def parse_options
  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
    opts.on("-c", "--config [ARG]", "Node configuration File") do |opt|
      @config_file = opt
    end
    opts.on("-h", "--help", "Help") do
      puts opts
      exit
    end
  end.parse!
end

class Monitoring < ActiveRecord::Base
  ActiveRecord::Base.default_timezone=:utc
end

class Schema < ActiveRecord::Migration
  def change
    create_table :monitorings do |t|
      t.string :name
      t.text :description
      t.text :push_output_log, :limit => 10000
      t.datetime :timestamp
      t.integer :push_status
      t.integer :http_code
      t.float :latency
      t.float :duration
      t.string :framework
      t.string :runtime
      t.string :databases
      t.string :memory_usage
      t.integer :http_status
      t.text :url_content, :limit => 1000
    end

    add_index(:monitorings, :name)
  end
end

def configure
  @config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)
  parse_options
  $config = Uhuru::Webui::Config.from_file(@config_file)
  setup_logging

  @cf = $config[:monitoring][:vmc_executable_path]

  @cloud_target = $config[:cloud_controller_url]
  @domain = $config[:monitoring][:apps_domain][0]
  @app_dir = File.expand_path("../../test_apps", __FILE__)
  @manifest_dir = File.join(@app_dir, 'manifests')

  @username = $config[:monitoring][:cloud_user]
  @password = $config[:monitoring][:cloud_password]
  @default_org = $config[:monitoring][:default_org]
  @default_space = $config[:monitoring][:default_space]
  @database = $config[:monitoring][:database]
  @sleep_after_app_push = $config[:monitoring][:sleep_after_app_push]
  @pause_after_each_app = $config[:monitoring][:pause_after_each_app]

  @app_definitions = YAML::load_file(File.expand_path("../../config/app-definitions.yml", __FILE__))
  @apps_to_monitor = []
  @components = $config[:monitoring][:components]

  @admin_file = $config[:admin_config_file]

  Uhuru::Webui::AdminSettings.bootstrap(@admin_file)

  @admin = Uhuru::Webui::AdminSettings.from_file(@admin_file)

  $config = Uhuru::Webui::AdminSettings.merge_config($config, @admin)

end

def bootstrap_monitoring
  # get monitoring user from uaa
  users_setup = UsersSetup.new($config)
  user = users_setup.uaa_get_user_by_name(@username)
  # create monitoring user in uaa if doesn't exist
  if user == nil
    uaac = users_setup.get_uaa_client

    emails = [@username]
    info = {userName: @username, password: @password, name: {givenName: "monitoring", familyName: "user"}}
    info[:emails] = emails.respond_to?(:each) ?
        emails.each_with_object([]) { |email, o| o.unshift({:value => email}) } :
        [{:value => (emails || name)}]

    user = uaac.add(:user, info)
    user_id = user['id']
  else
    user_id = user
  end

  admin_token = users_setup.get_admin_token

  client = CFoundry::V2::Client.new(@cloud_target, admin_token)
  #check if user exists in ccdb, and create it if not
  user = client.users.find { |u|
    u.guid == user_id
  }
  unless user
    user_cf = client.user
    user_cf.guid = user_id
    user_cf.create!
  end

  # check if monitoring org exists
  org = client.organizations.find { |o|
    o.name == @default_org
  }
  # create monitoring org with admin privileges
  unless org
    new_org = client.organization
    new_org.name = @default_org
    if new_org.create!
      users_obj = Library::Users.new(client.token, client.target)
      users_obj.add_user_to_org_with_role(new_org.guid, user_id, ['owner', 'billing'])
    end
    org = new_org
  end

  # check if monitoring space exists
  space = client.spaces.find { |s|
    s.name == @default_space
  }
  # create monitoring space with admin privileges
  unless space
    new_space = client.space
    new_space.organization = org
    new_space.name = @default_space
    if new_space.create!
      users_obj = Library::Users.new(client.token, client.target)
      users_obj.add_user_with_role_to_space(new_space.guid, user_id, ['owner', 'developer'])
    end
  end

  # get existing service authorisation tokens
  existing_service_auth_tokens = []
  client.service_auth_tokens.each do |s|
    existing_service_auth_tokens << s.label
  end

  # add service authorisation tokens
  @components[:services].each do |s|
    service = s["name"]
    service.slice!("_node")
    if !existing_service_auth_tokens.include?(service)
      service_auth_token = client.service_auth_token
      service_auth_token.label = service
      service_auth_token.provider = "core"
      service_auth_token.token = s["token"]
      service_auth_token.create!
    end
  end
end

def setup_logging
  steno_config = Steno::Config.to_config_hash($config[:logging])
  steno_config[:context] = Steno::Context::ThreadLocal.new
  Steno.init(Steno::Config.new(steno_config))
end

def logger
  @logger ||= Steno.logger("monitoring")
end

def initialize_activeresource
  ActiveRecord::Base.configurations = @database
  ActiveRecord::Base.establish_connection(@database)

  begin
    Schema.new.change
    logger.info("Created table in database at path: #{@database}")
  rescue => e
    logger.warn("Assuming database tables already exist - #{e.message}:#{e.backtrace}")
    nil
  end
end

def send_email(subject, body)
  email = $config[:monitoring][:email_to]
  Email.send_email(email, subject, body)
  logger.info("Email sent to #{email}. Subject: #{subject} Body: #{body}")
end

def cf_target
  target_command = "#{@cf.chomp('"')} --script target #{@cloud_target}" + '"'
  %x(#{target_command})
  if $?.exitstatus != 0
    raise Exception, "Target is unavailable"
  end
end

def cf_login
  login_command = "#{@cf.chomp('"')} --script login #{@username} --password #{@password} -o #{@default_org} -s #{@default_space}" + '"'
  login = %x(#{login_command})
  if login.downcase.include?("error") || login.downcase.include?("problem")
    logger.error("Unable to login in vmc. vmc error: #{login.strip}")
    raise Exception, "Unable to login in vmc. vmc error: #{login.strip}"
  end
end

def set_cfoundry_environment
  org = @client.organizations.find { |o|
    o.name == @default_org
  }
  @client.current_organization = org

  space = @client.spaces.find { |s|
    s.name == @default_space
  }
  @client.current_space = space

end


def get_services
  services = []
  @components[:services].each do |s|
    service = s["name"]
    service.slice!("_node")
    services << service
  end
  return services
end

def set_services
  services = get_services

  @app_definitions.each do |app|
    app_name = app['name']

    if File.exist?(File.join(@manifest_dir, app_name, 'manifest.yml'))
      begin
        manifest = YAML.load_file(File.join(@manifest_dir, app_name, 'manifest.yml'))

        app_service = manifest['applications'][0]['services'].first[1]['label']

        if services.include?(app_service)

          @apps_to_monitor << app_name

        end
      rescue => e
        logger.warn("Can't read manifest for app #{app_name} - #{e.message}:#{e.backtrace}")
      end
    end
  end
end

def app_latency(url)
  duration = Benchmark.measure do
    app_url_content_response_code(url)
  end

  duration.real.round(2)
end

def app_mem(app_name)
  app = get_app_by_name(app_name)
  memory = 0
  if app != nil && app.stats["0"][:state] != "DOWN"
    memory = app.stats["0"][:stats][:mem_quota]
  end
  memory
end

def get_app_by_name(app_name)
  app = @client.apps.find { |a|
    a.name == app_name
  }
  app
end

def app_url_content_response_code(url)
  uri = URI.parse(url)
  content = Net::HTTP.get(uri)
  code = Net::HTTP.get_response(uri).code

  return content, code
rescue
  return '', 0
end

def app_delete_with_service(app_name)
  app = get_app_by_name(app_name)

  services = []

  if app
    app.service_bindings.each do |service|
      services << service.service_instance
    end

    routes = app.routes

    if app.delete!
      routes.each do |route|
        route.delete!
      end

      services.each do |service|
        service.delete!
      end
    end
  end

end

def delete_all_apps_and_services()
  @client.apps.each do |app|
    app_delete_with_service(app.name)
  end
end

def main_apps
  app_names = @apps_to_monitor
  faulty_apps = []
  #mutex = Mutex.new
  #db_mutex = Mutex.new
  error_mail_body = String.new
  #threads = []

  app_names.each do |app|
    #threads << Thread.new do
      begin
        app_new_name = "#{app}#{APP_NAME_SUFFIX}#{SecureRandom.uuid.slice(0, 5)}"

        begin
          app_manifest_file = File.join(@manifest_dir, app, 'manifest.yml')
          app_manifest = YAML.load_file(app_manifest_file)

          app_manifest['applications'][0]['name'] = "#{app_new_name}"
          app_manifest['applications'][0]['host'] = "#{app_new_name}"
          app_manifest['applications'][0]['domain'] = "#{@domain}"

          destination_manifest_file = File.join(@app_dir, app, 'manifest.yml')
          File.open(destination_manifest_file, "w") { |f| YAML::dump(app_manifest, f) }
          manifest_hash = app_manifest['applications'][0]
        rescue Exception => e
          logger.error("Application '#{app}' manifest doesn't exist or is empty, application will not be processed - #{e.message}:#{e.backtrace}")
          error_mail_body << "Application '#{app}' manifest doesn't exist or is empty, application will not be processed.<br /><br />"
        end

        readme_file = File.join(@app_dir, app, 'readme.md')
        app_description = File.exist?(readme_file) ? File.read(readme_file) : ''

        push_output = ''
        push_duration = Benchmark.measure do
          push_command = "#{@cf.chomp('"')} push --script --manifest #{File.join(@app_dir, app, "/manifest.yml")} --trace" + '"'
          push_output = %x(#{push_command})
        end
        push_success = $?.exitstatus == 0 ? 1 : 0

        sleep(@sleep_after_app_push)

        total_mem = app_mem(app_new_name)
        latency = app_latency("http://#{app_new_name}.#{@domain}/")
        url_content, response_code = app_url_content_response_code("http://#{app_new_name}.#{@domain}")
        http_status = response_code == "200" ? 1 : 0

        databases = []
        manifest_hash['services'].each do |s|
          databases << s[1]["label"]
        end

        framework = app.to_s.split("with")[0]

        #mutex.synchronize {
          faulty_apps << {
              :name => app,
              :push_log => push_output,
              :framework => framework,
              :services => databases
          } if push_success * http_status == 0
        #}

        #db_mutex.synchronize {
          monit = Monitoring.new
          monit.name = app_new_name
          monit.description = app_description
          monit.push_output_log = push_output
          monit.timestamp = DateTime.current.new_offset(Rational(0, 24))
          monit.push_status = push_success
          monit.http_code = response_code
          monit.latency = latency
          monit.duration = push_duration.real.round(2)
          monit.framework = framework
          monit.runtime = ""
          monit.databases = databases.join(", ")
          monit.memory_usage = total_mem
          monit.http_status = http_status
          monit.url_content = url_content
          monit.save!

          ActiveRecord::Base.connection.close
        #}
      rescue => e
        logger.error("Error processing app #{app} - #{e.message}:#{e.backtrace}")
      end

      logger.info("Finished processing application #{app_new_name}")

      app_delete_with_service(app_new_name)
      logger.info("Application #{app} deleted")
    #end

    sleep(@pause_after_each_app)
  end

  #threads.each do |t|
  #  t.join
  #end

  if faulty_apps.count > 0
    error_mail_body << <<ERROR_MAIL
Some problems were detected around <b>#{ Time.now.utc.to_s }</b>. <br />
You can find a list of malfunctioning frameworks and services below: <br />

<ul>
#{
    faulty_apps.map do |faulty_app|
      if (faulty_app[:push_log] =~ /Error.+$/)
        error_line = faulty_app[:push_log].split("<<<").select { |x| x[/Error.+$/] }[0].split(">>>", 2)[0].strip
      end
      "<li>App: <b>#{faulty_app[:name]}</b>; Framework: <b>#{faulty_app[:framework]}</b>; Services: <b>#{faulty_app[:services].join(', ')}</b>; Error short description: <b>#{error_line}</b></li>"
    end.join
    }
</ul>
<br />
<br />
Detailed Logs:
<br />
#{
    faulty_apps.map do |faulty_app|
      "<h3>#{faulty_app[:name]}</h3><pre>#{faulty_app[:push_log]}</pre>"
    end.join
    }
ERROR_MAIL

    send_email("#{@domain} QoS Monitoring [FAILURE]", error_mail_body)
  end
end

def get_apps(datetime_from, datetime_until)
  applications = Monitoring.where("timestamp > ? AND timestamp <= ?", datetime_from, datetime_until).to_a
  return applications
end

# will return a distinct list of pairs framework-service readed from app-definitions.yml
# ex: framework_services = get_frameworks_services
def get_frameworks_services
  apps = @app_definitions.select { |a| @apps_to_monitor.include?(a["name"]) }

  apps.map do |x|
    {
        :name => x["name"],
        :framework => x["framework"],
        :service => x["service"]
    }
  end
end


#resolutionUnit can be: months, weeks, days, hours, minutes
#last half of day 30 minutes resolution => generate_report("minutes", 24, 30)
def generate_report(resolution_unit, sample_count, resolution)
  infos = ["Status", "Push Outcome", "App Online", "Push Duration", "Latency"]

  framework_services = get_frameworks_services
  framework_services << {:name => "All", :framework => "All", :service => "All"}
  framework_services = framework_services.sort { |a, b| [a[:framework], a[:service]] <=> [b[:framework], b[:service]] }

  header = ["Info", "Framework", "Service", "Uptime"]
  dashboard = Array.new
  framework_services.each do |sla|
    infos.each do |info|
      dashboard << {:info => info, :name => sla[:name], :framework => sla[:framework], :service => sla[:service], :uptime => 0, :sum_app_online => 0, :sum_app_count => 0}
    end
  end

  current_time = DateTime.current.new_offset(Rational(0, 24))

  minutes = ((current_time - current_time.change({:min => 0, :sec => 0})) * 24 * 60).to_i
  current_time = minutes > 30 ? current_time.change({:min => 30, :sec => 0}) : current_time.change({:min => 0, :sec => 0})

  xy_sum_all_app_online, xy_sum_all_app_count = 0, 0
  i = sample_count
  while i > 0
    t0 = current_time.advance(:"#{resolution_unit}" => resolution * -1 * i)
    t1 = t0.advance(:"#{resolution_unit}" => resolution)

    y_all_count, y_all_status, y_all_push_outcome, y_all_app_online, y_all_duration, y_all_latency = 0, 0, 0, 0, 0, 0
    x_sum_app_online, x_sum_app_count = 0, 0
    applications = get_apps(t0, t1)

    dashboard.each do |item|
      if (item[:framework] != "All" && item[:service] != "All")

        app_hash = applications.select do |app|
          app.name.include?(item[:name]) &&
              app.timestamp < t1 &&
              app.timestamp >= t0
        end

        if app_hash.count > 0

          push_outcome = app_hash.inject(0.0) { |result, element| result + element.push_status }
          app_online = app_hash.inject(0.0) { |result, element| result + element.http_status }
          duration = app_hash.inject(0.0) { |result, element| result + element.duration }
          latency = app_hash.inject(0.0) { |result, element| result + element.latency }
          status = app_hash.inject(0.0) { |result, element| result + (element.push_status * element.http_status) }

          case item[:info]
            when "Status"
              item[:"#{t0.to_s}"] = (status / app_hash.count).round(6)
              y_all_count = y_all_count + app_hash.count
              y_all_status = y_all_status + status
              y_all_app_online = y_all_app_online + app_online
              y_all_push_outcome = y_all_push_outcome + push_outcome
              y_all_duration = y_all_duration + duration
              y_all_latency = y_all_latency + latency
              x_sum_app_online = item[:sum_app_online] + app_online
              x_sum_app_count = item[:sum_app_count] + app_hash.count
              xy_sum_all_app_online = xy_sum_all_app_online + app_online
              xy_sum_all_app_count = xy_sum_all_app_count + app_hash.count
            when "Push Outcome"
              item[:"#{t0.to_s}"] = (push_outcome / app_hash.count).round(6)
            when "App Online"
              item[:"#{t0.to_s}"] = (app_online / app_hash.count).round(6)
            when "Push Duration"
              item[:"#{t0.to_s}"] = (duration / app_hash.count).round(6)
            when "Latency"
              item[:"#{t0.to_s}"] = (latency / app_hash.count).round(6)
            else
              item[:"#{t0.to_s}"] = ""
          end

          item[:sum_app_online] = x_sum_app_online
          item[:sum_app_count] = x_sum_app_count
          item[:uptime] = (100 * (x_sum_app_online / x_sum_app_count)).round(4) unless x_sum_app_count == 0
        else
          item[:"#{t0.to_s}"] = nil
        end
      end
    end

    dashboard.select { |x| x[:framework] == "All" && x[:service] == "All" }.inject([]) { |result, item|
      if (y_all_count != 0)
        case item[:info]
          when "Status"
            item[:"#{t0.to_s}"] = (y_all_status / y_all_count).round(6)
          when "Push Outcome"
            item[:"#{t0.to_s}"] = (y_all_push_outcome / y_all_count).round(6)
          when "App Online"
            item[:"#{t0.to_s}"] = (y_all_app_online / y_all_count).round(6)
          when "Push Duration"
            item[:"#{t0.to_s}"] = (y_all_duration / y_all_count).round(6)
          when "Latency"
            item[:"#{t0.to_s}"] = (y_all_latency / y_all_count).round(6)
          else
            item[:"#{t0.to_s}"] = ""
        end;
        item[:uptime] = (100 * (xy_sum_all_app_online / xy_sum_all_app_count)).round(4)
      else
        item[:"#{t0.to_s}"] = nil
      end
      result }


    header << t0.to_s

    i = i -1
  end

  dashboard.each do |hash|
    hash.delete(:name)
    hash.delete(:sum_app_online)
    hash.delete(:sum_app_count)
  end

  sort_keys = {}
  infos.each_with_index do |info, index|
    sort_keys[info] = index
  end

  dashboard.sort! do |a, b|
    if (a[:framework] == 'All') && (b[:framework] != 'All')
      -1
    elsif (b[:framework] == 'All') && (a[:framework] != 'All')
      1
    elsif a[:framework] == b[:framework] && a[:service] == b[:service]
      sort_keys[a[:info]] < sort_keys[b[:info]] ? -1 : 1
    else
      [a[:framework], a[:service]] <=> [b[:framework], b[:service]]
    end
  end

  return header, dashboard
end

def main

  configure
  logger.info("Monitoring started")
  bootstrap_monitoring
  initialize_activeresource

  begin
    cf_target
    cf_login

    users_setup = UsersSetup.new($config)
    token = users_setup.get_user_token(@username, @password)
    @client = CFoundry::V2::Client.new(@cloud_target, token)

    set_cfoundry_environment
    set_services
  rescue => e
    exception = "#{e.message}:#{e.backtrace}"
    send_email("#{@domain} QoS Monitoring [FAILURE]", 'There was a problem logging into the cloud.')
    logger.error("Uhuru monitoring could not start - #{exception}")
    raise
  end
  interrupted = false

  trap("TERM") { interrupted = true }
  while true
    start_time = DateTime.now
    delete_all_apps_and_services
    main_apps
    delete_all_apps_and_services

    report_data_cache_dir = File.expand_path('../../monitoring_cache', __FILE__)

    unless Dir.exist? report_data_cache_dir
      Dir.mkdir report_data_cache_dir
    end

    $config[:monitoring][:reports].each do |name, report|
      resolution = report[:resolution]
      resolution_unit = report[:resolution_unit]
      sample_count = report[:sample_count]

      header, data = generate_report(resolution_unit, sample_count, resolution)

      header_file = File.join(report_data_cache_dir, "#{name}.header")
      data_file = File.join(report_data_cache_dir, "#{name}.data")

      File.open(header_file, 'w') do |file|
        file << header.to_json
      end

      File.open(data_file, 'w') do |file|
        file << data.to_json
      end
    end

    sleep_time = 1500 - (Time.now - start_time).round
    if (sleep_time > 0)
      sleep sleep_time
    end

    if interrupted
      exit
    end

  end


rescue => e
  puts "#{e.message}: #{e.backtrace}"
  logger.error("#{e.message} #{e.backtrace}")
end

main

