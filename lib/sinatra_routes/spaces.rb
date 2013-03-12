require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Spaces
      def self.registered(app)

        app.get ORGANIZATION do
          if session[:login_] == false || session[:login_] == nil
            redirect INDEX
          end

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          credit_cards_Obj = CreditCards.new(session[:token], $cf_target)
          users_setup_Obj = UsersSetup.new($config)
          domains_Obj = Library::Domains.new(session[:token], $cf_target)
          all_users = users_setup_Obj.uaa_get_usernames

          organizations_Obj.set_current_org(params[:org_guid])
          spaces_list = organizations_Obj.read_spaces(params[:org_guid])
          owners_list = organizations_Obj.read_owners($config, params[:org_guid])
          billings_list = organizations_Obj.read_billings($config, params[:org_guid])
          auditors_list = organizations_Obj.read_auditors($config, params[:org_guid])
          domains_list = domains_Obj.read_domains()

          begin
            if (organizations_Obj.is_organization_billable?(@this_guid))
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
            error_message = $errors['update_organization_error']
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
                      :organization_name => organizations_Obj.get_name(params[:org_guid]),
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

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          credit_cards_Obj = CreditCards.new(session[:token], $cf_target)
          users_setup_Obj = UsersSetup.new($config)
          domains_Obj = Library::Domains.new(session[:token], $cf_target)
          all_users = users_setup_Obj.uaa_get_usernames

          organizations_Obj.set_current_org(params[:org_guid])
          spaces_list = organizations_Obj.read_spaces(params[:org_guid])
          owners_list = organizations_Obj.read_owners($config, params[:org_guid])
          billings_list = organizations_Obj.read_billings($config, params[:org_guid])
          auditors_list = organizations_Obj.read_auditors($config, params[:org_guid])
          domains_list = domains_Obj.read_domains()

          if params[:error] != '' && params[:error] != nil
            error_message = $errors['create_space_error']
            puts error_message
          else
            error_message = ''
          end

          begin
            if (organizations_Obj.is_organization_billable?(@this_guid))
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
                      :organization_name => organizations_Obj.get_name(params[:org_guid]),
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

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          credit_cards_Obj = CreditCards.new(session[:token], $cf_target)
          users_setup_Obj = UsersSetup.new($config)
          domains_Obj = Library::Domains.new(session[:token], $cf_target)
          all_users = users_setup_Obj.uaa_get_usernames

          organizations_Obj.set_current_org(params[:org_guid])
          spaces_list = organizations_Obj.read_spaces(params[:org_guid])
          owners_list = organizations_Obj.read_owners($config, params[:org_guid])
          billings_list = organizations_Obj.read_billings($config, params[:org_guid])
          auditors_list = organizations_Obj.read_auditors($config, params[:org_guid])
          domains_list = domains_Obj.read_domains()

          begin
            if (organizations_Obj.is_organization_billable?(@this_guid))
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
                      :organization_name => organizations_Obj.get_name(params[:org_guid]),
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

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          readapps_Obj = TemplateApps.new
          users_setup_Obj = UsersSetup.new($config)
          routes_Obj = Library::Routes.new(session[:token], $cf_target)
          all_space_users = users_setup_Obj.uaa_get_usernames

          #session[:space_name] = spaces_Obj.get_name(@this_guid)

          spaces_Obj.set_current_space(params[:space_guid])
          apps_list = spaces_Obj.read_apps(params[:space_guid])
          services_list = spaces_Obj.read_service_instances(params[:space_guid])
          routes_list = routes_Obj.read_routes(params[:space_guid])

          owners_list = spaces_Obj.read_owners($config, params[:space_guid])
          developers_list = spaces_Obj.read_developers($config, params[:space_guid])
          auditors_list = spaces_Obj.read_auditors($config, params[:space_guid])

          collections = readapps_Obj.read_collections

          if params[:error] == 'update_space'
            error_message = $errors['update_space_error']

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
                      :organization_name => organizations_Obj.get_name(params[:org_guid]),
                      :space_name => spaces_Obj.get_name(params[:space_guid]),
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
                      :error_message => error_message
                  }
              }
        end

        app.post '/createSpace' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          create = spaces_Obj.create(params[:org_guid], params[:spaceName])

          if create == 'error'
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces/create_space" + '?error=create_space'
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
          end
        end

        app.post '/deleteSpace' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          delete = spaces_Obj.delete(params[:spaceGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces" + '?error=delete_space'
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/spaces"
          end
        end

        app.post '/updateSpace' do
          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          spaces_Obj = Library::Spaces.new(session[:token], $cf_target)
          update = spaces_Obj.update(params[:modified_name], params[:current_space])

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