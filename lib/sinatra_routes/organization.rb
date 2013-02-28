require 'organizations'

module Uhuru::Webui
  module SinatraRoutes
    module Organization
      def self.registered(app)

        app.get ORGANIZATIONS + '/:org_guid' do

          organizations_Obj = Library::Organizations.new(session[:token], $cf_target)
          credit_cards_Obj = CreditCards.new(session[:token], $cf_target)
          users_setup_Obj = UsersSetup.new($config)
          all_users = users_setup_Obj.uaa_get_usernames

          session[:organization_name] = organizations_Obj.get_name(params[:org_guid])

          #session[:currentOrganization] = @this_guid
          #session[:currentOrganization_Name] = organizations_Obj.get_name(@this_guid)

          organizations_Obj.set_current_org(params[:org_guid])
          spaces_list = organizations_Obj.read_spaces(params[:org_guid])
          owners_list = organizations_Obj.read_owners($config, params[:org_guid])
          billings_list = organizations_Obj.read_billings($config, params[:org_guid])
          auditors_list = organizations_Obj.read_auditors($config, params[:org_guid])

          begin
            billing_manager_guid = "58f6e4e9-e4f2-47bb-b8b5-a1629457992d"  # will be billings_list[0].guid
            credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(@this_guid, billing_manager_guid)
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

      end
    end
  end
end