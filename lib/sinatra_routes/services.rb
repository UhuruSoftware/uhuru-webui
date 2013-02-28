require 'sinatra/base'


#Service plan should not be hardcoded

module Uhuru::Webui
  module SinatraRoutes
    module Services
      def self.registered(app)

        app.post '/createService' do

          @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = ServiceInstances.new(session[:token], $cf_target)


          spaces_Obj.create_service_instance(params[:serviceName], session[:currentSpace], @plan)

          #redirect "/space" + session[:currentSpace]
        end

        app.post '/deleteService' do

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)
          applications_Obj = Applications.new(session[:token], $cf_target)
          services_Obj = ServiceInstances.new(session[:token], $cf_target)

          services_Obj.delete(params[:serviceGuid])

          #redirect "/space" + session[:currentSpace]

        end

      end
    end
  end
end