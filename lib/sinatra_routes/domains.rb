require 'sinatra/base'

module Uhuru::Webui
  module Sinatra
    module Domains
      def self.registered(app)

        app.get DOMAINS do

        end

        app.get DOMAINS_CREATE do

        end

      end
    end
  end
end