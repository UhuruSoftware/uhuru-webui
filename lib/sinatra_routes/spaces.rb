require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Spaces
      def self.registered(app)

        app.get ORGANIZATION do
          redirect SPACES
        end

        app.get SPACES do

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          credit_cards_Obj = CreditCards.new(session[:token], $cf_target)
          users_setup_Obj = UsersSetup.new($config)
          all_users = users_setup_Obj.uaa_get_usernames

          session[:organization_name] = organizations_Obj.get_name(params[:org_guid])

          organizations_Obj.set_current_org(params[:org_guid])
          spaces_list = organizations_Obj.read_spaces(params[:org_guid])
          owners_list = organizations_Obj.read_owners($config, params[:org_guid])
          billings_list = organizations_Obj.read_billings($config, params[:org_guid])
          auditors_list = organizations_Obj.read_auditors($config, params[:org_guid])

          begin
            billing_manager_guid = "58f6e4e9-e4f2-47bb-b8b5-a1629457992d"
            credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(params[:org_guid], billing_manager_guid)
          rescue Exception => ex
            credit_card_type = nil
            credit_card_masked_number = nil
            puts "Exception raised for credit card type and masked number!"
            puts ex
          end

          erb :'user_pages/organization',
              {
                  :layout => :'layouts/user',
                  :locals => {
                      :card_type => credit_card_type,
                      :card_masked_number => credit_card_masked_number,
                      :all_users => all_users,
                      :spaces_list => spaces_list,
                      :spaces_count => spaces_list.count,
                      :members_count => owners_list.count + billings_list.count + auditors_list.count,
                      :owners_list => owners_list,
                      :billings_list => billings_list,
                      :auditors_list => auditors_list
                  }
              }

        end

        app.get SPACES_CREATE do

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)

          spaces_Obj.create(session[:currentOrganization], params[:spaceName])
          redirect ORGANIZATIONS #+ session[:currentOrganization]

        end


        app.get SPACE do

          if session[:login_] == false
            redirect INDEX
          end

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)
          readapps_Obj = TemplateApps.new
          users_setup_Obj = UsersSetup.new($config)
          all_space_users = users_setup_Obj.uaa_get_usernames

          @this_guid =

          #session[:space_name] = spaces_Obj.get_name(@this_guid)

          spaces_Obj.set_current_space(params[:space_guid])
          apps_list = spaces_Obj.read_apps(params[:space_guid])
          services_list = spaces_Obj.read_service_instances(params[:space_guid])

          owners_list = spaces_Obj.read_owners($config, params[:space_guid])
          developers_list = spaces_Obj.read_developers($config, params[:space_guid])
          auditors_list = spaces_Obj.read_auditors($config, params[:space_guid])

          collections = readapps_Obj.read_collections

          erb :space,
              {
                  :layout => :layout_user,
                  :locals => {
                      :collections => collections,
                      :all_space_users => all_space_users,
                      :owners_list => owners_list,
                      :auditors_list => auditors_list,
                      :users_count => owners_list.count + developers_list.count + auditors_list.count,
                      :developers_list => developers_list,
                      :apps_list => apps_list,
                      :services_list => services_list,
                      :apps_count => apps_list.count,
                      :services_count => services_list.count
                  }
              }
        end



        app.post '/deleteCurrentSpace' do
          organizations_Obj = Organizations.new(session[:token], $cf_target)
          spaces_Obj = Spaces.new(session[:token], $cf_target)
          spaces_Obj.delete(session[:currentSpace])
          redirect "/organization" + session[:currentOrganization]
        end

      end
    end
  end
end