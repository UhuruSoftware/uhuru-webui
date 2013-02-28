require 'sinatra/base'

module Uhuru::Webui
  module Sinatra
    module Domains
      def self.registered(app)
        app.get '/' do

        end
      end
    end
  end
end