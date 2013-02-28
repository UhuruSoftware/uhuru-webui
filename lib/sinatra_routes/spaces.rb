require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Spaces
      def self.registered(app)
        app.get '/organizations/:organization_id/spaces' do

        end

        app.get '/organizations/:organization_id/spaces/:space_id' do

        end

      end
    end
  end
end