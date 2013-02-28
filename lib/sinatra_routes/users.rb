require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module Users
      def self.registered(app)

        app.get ORGANIZATION_MEMBERS do

        end

        app.get SPACE_MEMBERS do

        end

        app.get ORGANIZATION_MEMBERS_ADD do

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          users_Obj = Users.new(session[:token], $cf_target)
          users_Obj.invite_user_with_role_to_org(@config, params[:userEmail], session[:currentOrganization], params[:userType])

          redirect ORGANIZATIONS #+ session[:currentOrganization]
        end

        app.get SPACE_MEMBERS_ADD do

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          users_Obj = Users.new(session[:token], $cf_target)
          users_Obj.invite_user_with_role_to_space(@config, params[:userEmail], session[:currentSpace], params[:userType])

          redirect SPACES #+ session[:currentSpace]

        end



        app.post '/deleteUser' do
          @user_guid = params[:thisUser]
          @role = params[:thisUserRole]

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          users_Obj = Users.new(session[:token], $cf_target)
          users_Obj.remove_user_with_role_from_org(session[:currentOrganization], @user_guid, @role)

          redirect "/organization" + session[:currentOrganization]
        end

        app.post '/deleteSpaceUser' do
          @user_guid = params[:thisUser]
          @role = params[:thisUserRole]

          organizations_Obj = Organizations.new(session[:token], $cf_target)
          users_Obj = Users.new(session[:token], $cf_target)
          users_Obj.remove_user_with_role_from_space(session[:currentSpace], @user_guid, @role)

          redirect "/space" + session[:currentSpace]
        end

      end
    end
  end
end