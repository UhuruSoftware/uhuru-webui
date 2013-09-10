require 'organizations'

module Uhuru::Webui
  module SinatraRoutes
    module Organizations
      def self.registered(app)

        app.get ORGANIZATIONS do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          organizations_list = Library::Organizations.new(session[:token], $cf_target).read_all
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :error_message => error_message,
                      :organizations_count => organizations_list.count
                  }
              }
        end

        app.get ORGANIZATIONS_CREATE do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          organizations_list = Library::Organizations.new(session[:token], $cf_target).read_all
          error_message = params[:error] if defined?(params[:error])

          erb :'user_pages/organizations',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organizations_list => organizations_list,
                      :organizations_count => organizations_list.count,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/organizations_create'
                  }
              }
        end

        app.post '/createOrganization' do
          if params[:orgName].size >= 4
            create = Library::Organizations.new(session[:token], $cf_target).create($config, params[:orgName], session[:user_guid])
          else
            redirect ORGANIZATIONS_CREATE + '?error=The name is too short (min. 4 characters)'
          end

          if defined?(create.message)
            redirect ORGANIZATIONS_CREATE + "?error=#{create.description}"
          else
            redirect ORGANIZATIONS
          end
        end

        app.post '/deleteOrganization' do
          delete = Library::Organizations.new(session[:token], $cf_target).delete($config, params[:orgGuid])

          if defined?(delete.message)
            redirect ORGANIZATIONS + "?error=#{delete.description}"
          else
            redirect ORGANIZATIONS
          end
        end

        app.post '/updateOrganization' do
          if params[:modified_name].size >= 4
            update =  Library::Organizations.new(session[:token], $cf_target).update(params[:modified_name], params[:current_organization])
          else
            redirect redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + '?error=The name is too short (min. 4 characters)'
          end

          if defined?(update.message)
            redirect redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}" + "?error=#{update.description}"
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end