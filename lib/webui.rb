require 'yaml'
require 'config'
require 'dev_utils'
require 'date'
require 'sinatra/session'

module Uhuru::Webui
  class Webui < Sinatra::Base
    set :root, File.expand_path("../../", __FILE__)
    set :views, File.expand_path("../../views", __FILE__)
    set :public_folder, File.expand_path("../../public", __FILE__)
    set :session_fail, '/login'
    set :session_secret, 'secret!'
    enable :sessions

    def initialize(config)
      @config = config
      @cf_target = @config[:cloudfoundry][:cloud_controller_api]
      # this is a variable witch holds the / symbol to be rendered afterwards in css, it is used at breadcrumb navigation
      $slash = '<span class="breadcrumb_slash"> / </span>'

      # this is the time variable witch will be passed at every page at the bottom
      @time = Time.now
      $this_time = @time.strftime("%m/%d/%Y")
      $path_home = ""

      super()

      configure_sinatra
    end

    def configure_sinatra

    end

    #set :dump_errors, true
    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    error 404 do
      @timeNow = $this_time
      erb :error404, {:layout => :layout_error}
    end

    error do
      session[:error] = "#{request.env['sinatra.error'].to_s}"

    # / page errors
        if session[:error] == "login error"
          session[:e_login] = "Wrong email and/or password!"
          redirect '/reset'
        end

        if session[:error] == "user exists"
          session[:e_sign_up] = "Email already exists try another one!"
          redirect '/reset'
        end

        if session[:error] == "org create error"
          session[:e_sign_up] = "Server couldn't create the default organization!"
          redirect '/reset'
        end

        if session[:error] == "signup error"
          session[:e_sign_up] = "Server did not respond!"
          redirect '/reset'
        end

    # /account page errors
        if session[:error] == "Update user failed!"
            session[:e_update_user] = "Something went wrong please try again"
            redirect '/resetAccount'
        end

        if session[:error] == "Change password failed!"
            session[:e_update_password] = "Something went wrong please try again"
            redirect '/resetAccount'
        end
    # /creditcards page errors
        if session[:error] == "create credit failed"
            session[:e_create_credit] = "Create credit card failed, try again!"
            redirect '/resetCredit'
        end

        if session[:error] == "delete credit failed"
            session[:e_delete_credit] = "Delete credit card failed, try again!"
            redirect '/resetCredit'
        end

        if session[:error] == "delete credit failed"
            session[:e_add_credit] = "Add credit card failed, try again!"
            redirect '/resetOrganization'
        end

    # /organizations page errors
        if session[:error] == "create organization failed"
            session[:e_create_organization] = "You are not authorized to create organizations!"
            redirect '/resetOrganizations'
        end

        if session[:error] == "delete organization failed"
            session[:e_delete_organization] = "You are not authorized to delete this organization!"
            redirect '/resetOrganizations'
        end

    # /organization(guid) - spaces - page errors
        if session[:error] == "create space failed"
            session[:e_create_space] = "You are not authorized to create spaces!"
            redirect '/resetOrganization'
        end

        if session[:error] == "delete space failed"
            session[:e_delete_space] = "You are not authorized to delete this space!"
            redirect '/resetOrganization'
        end

        if session[:error] == "User account doesn't exist"
            session[:e_create_user] = "You are not authorized to create a user!"
            redirect '/resetOrganization'
        end

        if session[:error] == "delete user error"
            session[:e_delete_user] = "You are not authorized to delete this user!"
            redirect '/resetOrganization'
        end

    # /space(guid) - current space - page errors
        if session[:error] == "create app error"
            session[:e_create_app] = "App was not created: server error!"
            redirect '/resetSpace'
        end

        if session[:error] == "create app error"
            session[:e_update_app] = "App was not updated: server error!"
            redirect '/resetSpace'
        end

        if session[:error] == "delete app error"
            session[:e_delete_app] = "App was not deleted: server error!"
            redirect '/resetSpace'
        end

        if session[:error] == "create service error"
            session[:e_create_service] = "Service was not created: server error!"
            redirect '/resetSpace'
        end

        if session[:error] == "delete service error"
            session[:e_delete_service] = "Service was not deleted: server error!"
            redirect '/resetSpace'
        end

        if session[:error] == "start app error"
            session[:e_start_app] = "Can't start app!"
            redirect '/resetSpace'
        end

        if session[:error] == "stop app error"
            session[:e_stop_app] = "Can't stop app!"
            redirect '/resetSpace'
        end

        if session[:error] == "bind service error"
            session[:e_bind_service] = "Can't bind this service to app!"
            redirect '/resetSpace'
        end

        if session[:error] == "unbind service error"
            session[:e_unbind_service] = "Can't unbind this service from app!"
            redirect '/resetSpace'
        end

        if session[:error] == "bind url error"
            session[:e_bind_url] = "Can't bind this url to app!"
            redirect '/resetSpace'
        end

        if session[:error] == "unbind url error"
            session[:e_unbind_url] = "Can't unbind this url from app!"
            redirect '/resetSpace'
        end

      erb :error500, {:layout => :layout_error}
    end

    get '/reset' do
      session[:e_reset] = true
      redirect '/'
    end

    get '/resetAccount' do
      session[:e_reset_account] = true
      redirect '/account'
    end

    get '/resetCredit' do
      session[:e_reset_credit] = true
      redirect '/credit'
    end

    get '/resetOrganizations' do
      session[:e_reset_organizations] = true
      redirect '/organizations'
    end

    get '/resetOrganization' do
      session[:e_reset_organization] = true
      redirect '/organization' + session[:currentOrganization]
    end

    get '/resetSpace' do
      session[:e_reset_space] = true
      redirect '/space' + session[:currentSpace]
    end




    get '/' do
      session[:login_] = false
      session[:error] = nil


      #this code resets the error handling  #>>
      if session[:e_reset] == true
        puts session[:e_reset]
      else
        session[:e_login] = ""
        session[:e_sign_up] = ""
      end
      session[:e_reset] = false
      # <<


      session = []
      @timeNow = $this_time
      @title = 'Uhuru App Cloud'
      $path_1 = ''
      $path_2 = ''

      $user = nil

      erb :index, {:layout => :layout_guest}
    end

    post '/login' do
      if params[:username]
        @username = params[:username]
        @password = params[:password]

        user_login = UsersSetup.new(@config)
        user = user_login.login(@username, @password)
        session[:token] = user.token
        session[:login_] = true

        session[:fname] = user.first_name
        session[:lname] = user.last_name
        session[:username] = params[:username]
        session[:user_guid] = user.guid
        session[:secret] = session[:session_id]

        redirect '/organizations'
      else
        redirect '/'
      end
    end

    get '/logout' do
      redirect '/'
    end

    post '/signup' do
      @email = params[:email]
      @password = params[:password]
      @given_name = params[:first_name]
      @family_name = params[:last_name]

      user_sign_up = UsersSetup.new(@config)
      user = user_sign_up.signup(@email, @password, @given_name, @family_name)

      session[:token] = user.token
      session[:login_] = true
      session[:fname] = user.first_name
      session[:lname] = user.last_name
      session[:username] = params[:username]
      session[:user_guid] = user.guid
      session[:secret] = session[:session_id]

      redirect '/organizations'
    end

    get '/infopage' do
      @title = "Uhuru Info"
      @timeNow = $this_time

      $path_1 = ''
      $path_2 = ''

      erb :infopage, {:layout => :layout_infopage}
    end

    get '/organizations' do

      if session[:login_] == false
        redirect '/'
      end

      #this code resets the error handling  #>>
      if session[:e_reset_organizations] == true
        puts session[:e_reset_organizations]
      else
        session[:e_login] = ""
        session[:e_sign_up] = ""
        session[:e_create_organization] = ""
        session[:e_delete_organization] = ""
      end
      session[:e_reset_organizations] = false
      # <<

      @this_user = session[:username]

      @usertitle = @this_user
      @timeNow = $this_time

      session[:path_1] = ''
      session[:path_2] = ''
      $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      organizations_list = organizations_Obj.read_all

      session[:currentOrganization] = nil
      session[:currentSpace] = nil

      erb :organizations, {:locals => {:organizations_list => organizations_list, :organizations_count => organizations_list.count}, :layout => :layout_user}
    end

    get '/organization:org_guid' do

      if session[:login_] == false
        redirect '/'
      end

      #this code resets the error handling  #>>
      if session[:e_reset_organization] == true
        puts session[:e_reset_organization]
      else
        session[:e_create_organization] = ""
        session[:e_delete_organization] = ""
        session[:e_create_space] = ""
        session[:e_delete_space] = ""
        session[:e_create_user] = ""
        session[:e_delete_user] = ""
        session[:e_add_credit] = ""
      end
      session[:e_reset_organization] = false
      # <<

      @timeNow = $this_time

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      credit_cards_Obj = CreditCards.new(session[:token], @cf_target)

      @this_guid = params[:org_guid]
      session[:organization_name] = organizations_Obj.get_name(@this_guid)
      session[:path_1] = $slash + '<a href="/organization' + @this_guid + ' "class="breadcrumb_element" id="element_organization">' + session[:organization_name] + '</a>'
      session[:path_2] = ''
      $path_home = '<a href="/organizations" class="breadcrumb_element_home">ORGANIZATIONS</a>'

      session[:currentOrganization] = @this_guid
      session[:currentOrganization_Name] = organizations_Obj.get_name(@this_guid)
      session[:currentSpace] = nil

      organizations_Obj.set_current_org(@this_guid)
      spaces_list = organizations_Obj.read_spaces(@this_guid)
      owners_list = organizations_Obj.read_owners(@config, @this_guid)
      billings_list = organizations_Obj.read_billings(@config, @this_guid)
      auditors_list = organizations_Obj.read_auditors(@config, @this_guid)

      credit_cards_list = credit_cards_Obj.read_all()
      org_credit_card = credit_cards_Obj.get_organization_credit_card(session[:currentOrganization])

      erb :organization, {:locals => {:credit_cards_list => credit_cards_list, :org_credit_card => org_credit_card, :spaces_list => spaces_list, :spaces_count => spaces_list.count, :members_count => owners_list.count + billings_list.count + auditors_list.count, :owners_list => owners_list, :billings_list => billings_list, :auditors_list => auditors_list}, :layout => :layout_user}
    end

    get '/space:space_guid' do

      if session[:login_] == false
        redirect '/'
      end

      #this code resets the error handling  #>>
      if session[:e_reset_space] == true
        puts session[:e_reset_space]
      else
        session[:e_create_space] = ""
        session[:e_delete_space] = ""
        session[:e_create_user] = ""
        session[:e_delete_user] = ""
        session[:e_create_app] = ""
        session[:e_update_app] = ""
        session[:e_delete_app] = ""
        session[:e_start_app] = ""
        session[:e_stop_app] = ""
        session[:e_bind_service] = ""
        session[:e_unbind_service] = ""
        session[:e_bind_url] = ""
        session[:e_unbind_url] = ""
        session[:e_create_service] = ""
        session[:e_delete_service] = ""
      end
      session[:e_reset_space] = false
      # <<

      @timeNow = $this_time

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)
      readapps_Obj = TemplateApps.new

      @this_guid = params[:space_guid]

      session[:space_name] = spaces_Obj.get_name(@this_guid)
      session[:path_2] = $slash + '<a href="/space' + @this_guid + '" class="breadcrumb_element" id="element_space">' + session[:space_name] + '</a>'

      session[:currentSpace] = @this_guid
      session[:currentSpace_Name] = spaces_Obj.get_name(@this_guid)

      spaces_Obj.set_current_space(@this_guid)
      apps_list = spaces_Obj.read_apps(@this_guid)
      services_list = spaces_Obj.read_service_instances(@this_guid)

      apps_names = readapps_Obj.read_apps

      owners_list = spaces_Obj.read_owners(@config, session[:currentSpace])
      developers_list = spaces_Obj.read_developers(@config, session[:currentSpace])
      auditors_list = spaces_Obj.read_auditors(@config, session[:currentSpace])

      erb :space, {:locals => {:owners_list => owners_list, :auditors_list => auditors_list, :developers_list => developers_list, :apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
    end

    get '/credit' do

      if session[:login_] == false
        redirect '/'
      end

      #this code resets the error handling  #>>
      if session[:e_reset_credit] == true
        puts session[:e_reset_credit]
      else
        session[:e_create_credit] = ""
        session[:e_delete_credit] = ""
      end
      session[:e_reset_credit] = false
      # <<

      @usertitle = session[:username]
      @timeNow = $this_time

      session[:path_1] = ''
      session[:path_2] = ''
      $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'

      credit_cards_Obj = CreditCards.new(session[:token], @cf_target)
      my_credit_cards = credit_cards_Obj.read_all

      erb :creditcard, {:locals => {:my_credit_cards => my_credit_cards}, :layout => :layout_user}
    end

    get '/account' do

      if session[:login_] == false
        redirect '/'
      end

      #this code resets the error handling  #>>
      if session[:e_reset_account] == true
        puts session[:e_reset_account]
      else
        session[:e_update_user] = ""
        session[:e_update_password] = ""
      end
      session[:e_reset_account] = false
      # <<

      @usertitle = "Account " + session[:username]
      @timeNow = $this_time

      session[:path_1] = ''
      session[:path_2] = ''
      $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'


      erb :usersettings, {:layout => :layout_user}
    end

    post '/createCard' do
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      @card_number = params[:card_number]
      @expiration_year = params[:expiration_year]
      @expiration_month = params[:expiration_month]

      @card_type = params[:card_type]
      @cvv = params[:cvv]
      @address1 = params[:address1]
      @address2 = params[:address2]

      @city = params[:city]
      @state = params[:state]
      @zip = params[:zip]
      @country = params[:country]

      credit_cards_Obj = CreditCards.new(session[:token], @cf_target)
      credit_cards_Obj.create(session[:user_guid], session[:username], @first_name, @last_name, @card_number, @expiration_year, @expiration_month, @card_type, @cvv)

      redirect "/credit"
    end

    post '/addCreditCardToOrganization' do
       @credit_card_id = params[:cardId]
       credit_cards_Obj = CreditCards.new(session[:token], @cf_target)
       @credit_card_org = credit_cards_Obj.add_organization_credit_card(session[:currentOrganization], @credit_card_id)

      redirect '/organization' + session[:currentOrganization]
    end

    post '/deleteClickedCreditCard' do
      @credit_card_id = params[:credit_card_id]

      credit_cards_Obj = CreditCards.new(session[:token], @cf_target)
      credit_cards_Obj.delete_by_id(@credit_card_id)

      redirect '/credit'
    end

    post '/createOrganization' do
      @name = params[:orgName]
      @organization_message = "Creating organization... Please wait"

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      organizations_Obj.create(@config, @name, session[:user_guid])
      redirect "/organizations"
    end

    post '/createSpace' do
      @name = params[:spaceName]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)

      spaces_Obj.create(session[:currentOrganization], @name)
      redirect "/organization" + session[:currentOrganization]
    end

    post '/updateOrganization' do
      @name = params[:m_organizationName]
      organizations_Obj = Organizations.new(session[:token], @cf_target)
      organizations_Obj.update(@name, session[:currentOrganization])
      redirect "/organization" + session[:currentOrganization]
    end

    post '/deleteCurrentOrganization' do
      organizations_Obj = Organizations.new(session[:token], @cf_target)
      organizations_Obj.delete(@config, session[:currentOrganization])
      redirect "/organizations"
    end

    post '/deleteClickedOrganization' do
      @guid = params[:orgGuid]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      organizations_Obj.delete(@config, @guid)
      redirect "/organizations"
    end

    post '/updateSpace' do
      @name = params[:m_spaceName]
      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)

      spaces_Obj.update(@name, session[:currentSpace])
      redirect "/space" + session[:currentSpace]
    end

    post '/deleteCurrentSpace' do
      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)
      spaces_Obj.delete(session[:currentSpace])
      redirect "/organization" + session[:currentOrganization]
    end

    post '/deleteClickedSpace' do
      @guid = params[:spaceGuid]
      puts @guid
      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)

      spaces_Obj.delete(@guid)
      redirect "/organization" + session[:currentOrganization]
    end

    post '/deleteClickedApp' do
      @guid = params[:appGuid]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)
      applications_Obj = Applications.new(session[:token], @cf_target)

      applications_Obj.delete(@guid)
      redirect "/space" + session[:currentSpace]
    end

    post '/deleteClickedService' do
      @guid = params[:serviceGuid]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)
      applications_Obj = Applications.new(session[:token], @cf_target)
      services_Obj = ServiceInstances.new(session[:token], @cf_target)

      services_Obj.delete(@guid)

      redirect "/space" + session[:currentSpace]
    end

    post '/createApp' do
      @name = params[:appName]
      @runtime = params[:appRuntime]
      @framework = params[:appFramework]
      @instance = 1
      @memory = params[:appMemory]
      @path = params[:appPath]
      @domain = params[:appDomain]
      @plan = params[:appPlan]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = Spaces.new(session[:token], @cf_target)
      apps_obj = Applications.new(session[:token], @cf_target)
      apps_obj.create(session[:currentOrganization], session[:currentSpace], @name, @runtime, @framework, @instance, @memory.to_i, @domain, @path, @plan)
      redirect "/space" + session[:currentSpace]
    end

    post '/createService' do
      @name = params[:serviceName]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      spaces_Obj = ServiceInstances.new(session[:token], @cf_target)

      @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

      spaces_Obj.create_service_instance(@name, session[:currentSpace], @plan)

      redirect "/space" + session[:currentSpace]
    end

    post '/addUsers' do
      @email = params[:userEmail]
      @type = params[:userType]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      users_Obj = Users.new(session[:token], @cf_target)
      users_Obj.invite_user_with_role_to_org(@config, @email, session[:currentOrganization], @type)

      redirect "/organization" + session[:currentOrganization]
    end

    post '/addUsersToSpace' do
      @email = params[:userEmail]
      @type = params[:userType]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      users_Obj = Users.new(session[:token], @cf_target)
      users_Obj.invite_user_with_role_to_space(@config, @email, session[:currentSpace], @type)

      redirect "/space" + session[:currentSpace]
    end

    post '/deleteUser' do
      @user_guid = params[:thisUser]
      @role = params[:thisUserRole]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      users_Obj = Users.new(session[:token], @cf_target)
      users_Obj.remove_user_with_role_from_org(session[:currentOrganization], @user_guid, @role)

      redirect "/organization" + session[:currentOrganization]
    end

    post '/deleteSpaceUser' do
      @user_guid = params[:thisUser]
      @role = params[:thisUserRole]

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      users_Obj = Users.new(session[:token], @cf_target)
      users_Obj.remove_user_with_role_from_space(session[:currentSpace], @user_guid, @role)

      redirect "/space" + session[:currentSpace]
    end

    post '/startApp' do
      @name = params[:appName]
      apps_obj = Applications.new(session[:token], @cf_target)

      apps_obj.start_app(@name)
      puts @name

      redirect "/space" + session[:currentSpace]
      erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
    end

    post '/stopApp' do
      @name = params[:appName]
      apps_obj = Applications.new(session[:token], @cf_target)

      apps_obj.stop_app(@name)
      puts @name

      redirect "/space" + session[:currentSpace]
    end

    post '/updateApp' do
      @name = params[:appName]
      @memory = params[:appMemory]
      @instances = params[:appInstances]

      apps_obj = Applications.new(session[:token], @cf_target)
      apps_obj.update(@name, @instances, @memory)

      redirect "/spaces" + session[:currentSpace]
    end

    post '/bindServices' do
      @app_name = params[:appName]
      @service_name = params[:serviceName]

      apps = Applications.new(session[:token], @cf_target)
      apps.bind_app_services(@app_name, @service_name)

      redirect "/space" + session[:currentSpace]
    end

    post '/unbindServices' do
      @app_name = params[:appName]
      @service_name = params[:serviceName]

      apps = Applications.new(session[:token], @cf_target)
      apps.unbind_app_services(@app_name, @service_name)

      redirect "/space" + session[:currentSpace]
    end

    post '/bindUri' do
      @app_name = params[:appName]
      @uri_name = params[:uriName]
      @domain_name = "api3.ccng-dev.net"

      apps = Applications.new(session[:token], @cf_target)
      apps.bind_app_url(@app_name, session[:currentOrganization], @domain_name, @uri_name)

      redirect "/space" + session[:currentSpace]
    end

    post '/unbindUri' do
      @app_name = params[:appName]
      @uri_name = params[:uriName]
      @domain_name = "http://api3.ccng-dev.net"

      apps = Applications.new(session[:token], @cf_target)
      apps.unbind_app_url(@app_name, @domain_name, @uri_name)

      redirect "/space" + session[:currentSpace]
    end

    post '/updateUserName' do
      @first_name = params[:first_name]
      @last_name = params[:last_name]

      user_sign_up = UsersSetup.new(@config)
      user_sign_up.update_user_info(session[:user_guid], @first_name, @last_name)

      redirect '/account'
    end

    post '/updateUserPassword' do
      @old_pass = params[:old_pass]
      @new_pass = params[:new_pass1]

      user_sign_up = UsersSetup.new(@config)
      user_sign_up.change_password(session[:user_guid], @new_pass, @old_pass)

      redirect '/account'
    end

    get '/tapps/zip/:file' do |file|

      file = File.join('../tapps/zip/wordpress.zip', file)
      send_file(file, :disposition => 'attachment', :filename => File.basename(file))

    end

  end
end
