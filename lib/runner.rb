require "steno"
require "config"
require "webui"
require "thin"
require "optparse"

module Uhuru::Webui
  class Runner
    def initialize(argv)
      @argv = argv

      # default to production. this may be overriden during opts parsing
      ENV["RACK_ENV"] = "production"
      # default config path. this may be overriden during opts parsing
      @config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)

      parse_options!

      @config = Uhuru::Webui::Config.from_file(@config_file)
      @config[:bind_address] = VCAP.local_ip(@config[:local_route])

      create_pidfile
      setup_logging
    end

    def logger
      @logger ||= Steno.logger("webui.runner")
    end

    def options_parser
      @parser ||= OptionParser.new do |opts|
        opts.on("-c", "--config [ARG]", "Configuration File") do |opt|
          @config_file = opt
        end

        opts.on("-d", "--development-mode", "Run in development mode") do
          # this must happen before requring any modules that use sinatra_routes,
          # otherwise it will not setup the environment correctly
          @development = true
          ENV["RACK_ENV"] = "development"
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
      config = @config.dup
      $config = config.dup

      webui = Uhuru::Webui::Webui.new(config);
      app = Rack::Builder.new do
        use Rack::Recaptcha, :public_key => $config[:recaptcha][:recaptcha_public_key], :private_key => $config[:recaptcha][:recaptcha_private_key]
        map "/" do
          run webui
        end
      end
      @thin_server = Thin::Server.new(@config[:bind_address], @config[:port], app)

      trap_signals

      # activate threaded only if required
      # @thin_server.threaded = true
      @thin_server.start!
    end

    def trap_signals
      ["TERM", "INT"].each do |signal|
        trap(signal) do
          @thin_server.stop! if @thin_server
          EM.stop
        end
      end
    end
  end
end
