require "vcap/common"
require 'vcap/config'

require "steno"
require "config"
require "admin_settings"
require "thin"
require "optparse"
require "class_with_feedback"
require "cf/registrar"

module Uhuru::Webui
  class Runner
    def initialize(argv)
      @argv = argv

      # default config path. this may be overridden during opts parsing
      @config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)


      parse_options!

      @config = Uhuru::Webui::Config.from_file(@config_file)

      ENV["RACK_ENV"] =  @config[:dev_mode] ? "development" : "production"

      @admin_file = @config[:admin_config_file]

      Uhuru::Webui::AdminSettings.bootstrap(@admin_file)

      @admin = Uhuru::Webui::AdminSettings.from_file(@admin_file)


      @config[:bind_address] = VCAP.local_ip(@config[:local_route])

      @config = Uhuru::Webui::AdminSettings.merge_config(@config, @admin)

      ClassWithFeedback.cleanup

      create_pidfile
      setup_logging
      @config[:logger] = logger
    end

    def logger
      $logger ||= Steno.logger("uhuru-webui.runner")
    end


    def options_parser
      @parser ||= OptionParser.new do |opts|
        opts.on("-c", "--config [ARG]", "Configuration File") do |opt|
          @config_file = opt
        end
      end
    end

    def parse_options!
      options_parser.parse! @argv
    rescue
      puts options_parser
      exit 1
    end

    def create_pidfile
      begin
        pid_file = VCAP::PidFile.new(@config[:pid_filename])
        pid_file.unlink_at_exit
      rescue => e
        puts "ERROR: Can't create pid file #{@config[:pid_filename]}"
        exit 1
      end
    end

    def setup_logging
      steno_config = Steno::Config.to_config_hash(@config[:logging])
      steno_config[:context] = Steno::Context::ThreadLocal.new
      Steno.init(Steno::Config.new(steno_config))
    end

    def run!
      EM.run do
        $config = @config.dup
        $admin = @admin.dup

        # Only load the Web UI after configurations are initialized and we're ready to run.
        require "webui"

        webui = Uhuru::Webui::Webui.new

        app = Rack::Builder.new do
          use Rack::CommonLogger
          use Rack::Recaptcha, :public_key => $config[:recaptcha][:recaptcha_public_key], :private_key => $config[:recaptcha][:recaptcha_private_key]
          map "/" do
            run webui
          end
        end
        @thin_server = Thin::Server.new(@config[:bind_address], @config[:port], app)

        trap_signals

        # activate threaded only if required
        @thin_server.threaded = true
        @thin_server.start!
        if ($config[:dev_mode] == false)
          registrar.register_with_router
        end

      end
    end


    def trap_signals
      ["TERM", "INT"].each do |signal|
        trap(signal) do
          if ($config[:dev_mode] == false)
            registrar.shutdown do
              @thin_server.stop! if @thin_server
              EM.stop
            end
          else
            @thin_server.stop! if @thin_server
            EM.stop
          end
        end
      end
    end


    def registrar
      @registrar ||= Cf::Registrar.new(
          :mbus => $config[:message_bus_uri],
          :host => $config[:bind_address],
          :port => $config[:port],
          :uri => $config[:domain],
          :tags => {:component => "WebUI"},
          :index => 0
      )
    end

  end
end
