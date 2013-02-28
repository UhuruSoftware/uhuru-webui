require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Account
      def self.registered(app)
        app.get '/' do

        end
      end
    end
  end
end