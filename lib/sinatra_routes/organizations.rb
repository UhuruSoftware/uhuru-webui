require 'organizations'

module Uhuru::Webui
  module SinatraRoutes
    module Organizations
      def self.registered(app)

        app.get ORGANIZATIONS do

          if session[:login_] == false || session[:login_] == nil
            redirect '/'
          end

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          organizations_list = organizations_Obj.read_all

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :organizations_count => organizations_list.count
                  }
              }
        end

        app.get ORGANIZATIONS_CREATE do

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          organizations_list = organizations_Obj.read_all

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :organizations_count => organizations_list.count,
                      :include_erb => :'user_pages/modals/organizations_create'
                  }
              }
        end

        app.post '/createOrganization' do
          #@organization_message = "Creating organization... Please wait"
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          organizations_Obj.create($config, params[:orgName], session[:user_guid])
          redirect ORGANIZATIONS
        end

        app.post '/deleteOrganization' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          organizations_Obj.delete($config, params[:orgGuid])
          redirect ORGANIZATIONS
        end

        app.post '/updateOrganization' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          organizations_Obj.update(params[:modified_name], params[:current_organization])
          redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
        end

      end
    end
  end
end