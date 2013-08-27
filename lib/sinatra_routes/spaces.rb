require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Spaces
      def self.registered(app)

        app.get ORGANIZATION do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          user = UsersSetup.new($config)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_users = user.uaa_get_usernames

          org.set_current_org(params[:org_guid])
          spaces_list = org.read_spaces(params[:org_guid])
          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          domains_list = domain.read_domains(params[:org_guid])

          begin
            if (org.is_organization_billable?(@this_guid))
              billing_manager_guid = billings_list[0].guid
              credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(@this_guid, billing_manager_guid)
            end
          rescue Exception => ex
            credit_card_type = nil
            credit_card_masked_number = nil
            puts 'Exception raised for credit card type and masked number!'
            puts ex
          end

          if params[:error] == 'update_organization'
            if params[:message] == 'name_size'
              error_message = $errors['organization_error_name_size']
            else
              error_message = $errors['update_organization_error']
            end
          elsif params[:error] == 'delete_space'
            error_message = $errors['delete_space_error']
          elsif params[:error] == 'delete_user'
            error_message = $errors['delete_user_error']
          elsif params[:error] == 'delete_domain'
            error_message = $errors['delete_domain_error']
          else
            error_message = ''
          end

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :card_type => credit_card_type,
                      :card_masked_number => credit_card_masked_number,
                      :all_users => all_users,
                      :spaces_list => spaces_list,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :domains_list => domains_list,
                      :error_message => error_message
                  }
              }
        end

        app.get SPACES_CREATE do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          user = UsersSetup.new($config)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_users = user.uaa_get_usernames

          org.set_current_org(params[:org_guid])
          spaces_list = org.read_spaces(params[:org_guid])
          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          domains_list = domain.read_domains()

          if params[:error] == 'create_space'
            if params[:message] == 'name_size'
              error_message = $errors['space_error_name_size']
            else
              error_message = $errors['create_space_error']
            end
          else
            error_message = ''
          end

          begin
            if (org.is_organization_billable?(@this_guid))
              billing_manager_guid = billings_list[0].guid
              credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(@this_guid, billing_manager_guid)
            end
          rescue Exception => ex
            credit_card_type = nil
            credit_card_masked_number = nil
            puts 'Exception raised for credit card type and masked number!'
            puts ex
          end

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :card_type => credit_card_type,
                      :card_masked_number => credit_card_masked_number,
                      :all_users => all_users,
                      :spaces_list => spaces_list,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/spaces_create'
                  }
              }
        end

        app.get ORGANIZATION_MEMBERS_ADD do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          user = UsersSetup.new($config)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_users = user.uaa_get_usernames

          org.set_current_org(params[:org_guid])
          spaces_list = org.read_spaces(params[:org_guid])
          owners_list = org.read_owners($config, params[:org_guid])
          billings_list = org.read_billings($config, params[:org_guid])
          auditors_list = org.read_auditors($config, params[:org_guid])
          domains_list = domain.read_domains()

          begin
            if (org.is_organization_billable?(@this_guid))
              billing_manager_guid = billings_list[0].guid
              credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(@this_guid, billing_manager_guid)
            end
          rescue Exception => ex
            credit_card_type = nil
            credit_card_masked_number = nil
            puts 'Exception raised for credit card type and masked number!'
            puts ex
          end

          if params[:error] != '' && params[:error] != nil
            error_message = $errors['add_user_error']
          else
            error_message = ''
          end

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :current_organization => params[:org_guid],
                      :current_tab => params[:tab],
                      :card_type => credit_card_type,
                      :card_masked_number => credit_card_masked_number,
                      :all_users => all_users,
                      :spaces_list => spaces_list,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list,
                      :domains_list => domains_list,
                      :error_message => error_message,
                      :include_erb => :'user_pages/modals/members_add'
                  }
              }
        end

        app.get SPACE do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          org = Library::Organizations.new(session[:token], $cf_target)
          space = Library::Spaces.new(session[:token], $cf_target)
          app = TemplateApps.new
          user = UsersSetup.new($config)
          route = Library::Routes.new(session[:token], $cf_target)
          domain = Library::Domains.new(session[:token], $cf_target)
          all_space_users = user.uaa_get_usernames

          space.set_current_space(params[:space_guid])
          apps_list = space.read_apps(params[:space_guid])
          services_list = space.read_service_instances(params[:space_guid])
          routes_list = route.read_routes(params[:space_guid])

          owners_list = space.read_owners($config, params[:space_guid])
          developers_list = space.read_developers($config, params[:space_guid])
          auditors_list = space.read_auditors($config, params[:space_guid])
          domains_list = domain.read_domains(params[:org_guid], params[:space_guid])

          collections = app.read_collections

          if params[:error] == 'update_space'
            if params[:message] == 'name_size'
              error_message = $errors['space_error_name_size']
            else
              error_message = $errors['update_space_error']
            end
          elsif params[:error] == 'delete_app'
            error_message = $errors['delete_app_error']

          elsif params[:error] == 'delete_service'
            error_message = $errors['delete_service_error']

          elsif params[:error] == 'delete_user'
            error_message = $errors['delete_user_error']
          else
            error_message = ''
          end

          erb :'user_pages/space',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :organization_name => org.get_name(params[:org_guid]),
                      :space_name => space.get_name(params[:space_guid]),
                      :current_organization => params[:org_guid],
                      :current_space => params[:space_guid],
                      :current_tab => params[:tab],
                      :collections => collections,
                      :all_space_users => all_space_users,
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :routes_list => routes_list,
                      :domains_list => domains_list,
                      :error_message => error_message
                  }
              }
        end

        app.post '/createSpace' do
          if params[:spaceName].size >= 4
            create = Library::Spaces.new(session[:token], $cf_target).create(params[:org_guid], params[:spaceName])
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + '?error=create_space&message=name_size'
          end

          if create == 'error'
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + '?error=create_space'
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
          end
        end

        app.post '/deleteSpace' do
          delete = Library::Spaces.new(session[:token], $cf_target).delete(params[:spaceGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces" + '?error=delete_space'
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
          end
        end

        app.post '/updateSpace' do
          if params[:modified_name].size >= 4
            update = Library::Spaces.new(session[:token], $cf_target).update(params[:modified_name], params[:current_space])
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=update_space&message=name_size'
          end

          if update == 'error'
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}" + '?error=update_space'
          else
            redirect ORGANIZATIONS + "/#{params[:current_organization]}/spaces/#{params[:current_space]}/#{params[:current_tab]}"
          end
        end

      end
    end
  end
end