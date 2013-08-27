require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Domains
      def self.registered(app)

        app.get DOMAINS_CREATE do
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

          if params[:error] == 'add_domain'
            error_message = $errors['create_domain_error']
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
                      :include_erb => :'user_pages/modals/domains_create'
                  }
              }
        end

        app.post '/createDomain' do
          wildcard = params[:domain_wildcard] ? true : false
          create = Library::Domains.new(session[:token], $cf_target).create(params[:domainName], params[:org_guid], wildcard)

          if create == 'error'
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains/add_domains" + '?error=add_domain'
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains"
          end
        end

        app.post '/deleteDomain' do
          delete = Library::Domains.new(session[:token], $cf_target).delete(params[:domainGuid])

          if delete == 'error'
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains" + '?error=delete_domain'
          else
            redirect ORGANIZATIONS + "/#{params[:org_guid]}/domains"
          end
        end

      end
    end
  end
end