require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Administration
      def self.registered(app)

        app.get ADMINISTRATION do
          require_admin

          erb :'admin/index', {
              :layout => :'layouts/admin',
              :locals => {
                  :current_tab => 'info'
              }
          }
        end

      end
    end
  end
end