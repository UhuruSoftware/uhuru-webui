require "steno"
require "config"
require "webui"
require "thin"

module Uhuru::Webui
  class Runner
    def initialize(argv)
      @config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)

      @config = Uhuru::Webui::Config.from_file(@config_file)
      @config[:bind_address] = VCAP.local_ip(@config[:local_route])

      create_pidfile
      setup_logging
    end

    def logger
      @logger ||= Steno.logger("cc.runner")
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

      app = Rack::Builder.new do
        # TODO: we really should put these bootstrapping into a place other
        # than Rack::Builder
        use Rack::CommonLogger

        map "/" do
          run Uhuru::Webui::Webui.new(config)
        end
      end
      @thin_server = Thin::Server.new(@config[:bind_address], @config[:port])
      @thin_server.app = app

      trap_signals

      @thin_server.threaded = true
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
