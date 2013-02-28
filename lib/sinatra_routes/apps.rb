require 'sinatra/base'


#
#    TODO:: There are some variables in this code that should not be hardcoded
#


module Uhuru::Webui
  module SinatraRoutes
    module Apps
      def self.registered(app)

        app.post '/createApp' do
          #@name =
          #@runtime =
          #@framework =
          instance = 1
          #@memory =
          #@path =
          #@domain =
          #@plan =

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)
          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.create(session[:currentOrganization], session[:currentSpace], params[:appName], params[:appRuntime], params[:appFramework], instance, params[:appMemory].to_i, params[:appDomain], params[:appPath], params[:appPlan])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/deleteApp' do

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)
          applications_Obj = Applications.new(session[:token], $cf_target)

          applications_Obj.delete(params[:appGuid])
          #redirect "/space" + session[:currentSpace]

        end



        app.post '/startApp' do

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.start_app(params[:appName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/stopApp' do

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.stop_app(params[:appName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/updateApp' do

          #@name =
          #@memory =
          #@instances =

          apps_obj = Applications.new(session[:token], $cf_target)
          apps_obj.update(params[:appName], params[:appInstances], params[:appMemory])

          #redirect "/spaces" + session[:currentSpace]

        end

        app.post '/bindServices' do

          apps = Applications.new(session[:token], $cf_target)
          apps.bind_app_services(params[:appName], params[:serviceName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/unbindServices' do

          apps = Applications.new(session[:token], $cf_target)
          apps.unbind_app_services(params[:appName], params[:serviceName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/bindUri' do

          @domain_name = "api3.ccng-dev.net"

          apps = Applications.new(session[:token], $cf_target)
          apps.bind_app_url(params[:appName], session[:currentOrganization], @domain_name, params[:uriName])

          #redirect "/space" + session[:currentSpace]

        end

        app.post '/unbindUri' do

          @domain_name = "http://api3.ccng-dev.net"

          apps = Applications.new(session[:token], $cf_target)
          apps.unbind_app_url(params[:appName], @domain_name, params[:uriName])

          #redirect "/space" + session[:currentSpace]

        end


      end
    end
  end
end