require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Services
      def self.registered(app)
        app.get '/' do

        end
      end
    end
  end
end