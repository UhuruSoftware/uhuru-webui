require 'organizations'

module Uhuru::Webui
  module SinatraRoutes
    module Organizations
      def self.registered(app)

        app.get ORGANIZATIONS do
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
                      :include_erb => :'user_pages/organizations_create'
                  }
              }
        end

        app.put ORGANIZATIONS do

        end

        app.post ORGANIZATIONS do
          puts "delete org"
          redirect ORGANIZATIONS
        end

        app.get '/testme/now' do

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          organizations_list = organizations_Obj.read_all

          erb :'user_pages/organizations',
              {
                  :layout => :'layout_user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :organizations_count => organizations_list.count,
                      :include_erb => :'user_pages/organizations_create'
                  }
              }
        end
      end
    end
  end
end