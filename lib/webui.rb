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
    set :sessions, true
    use Rack::Logger
    use Rack::Recaptcha, :public_key => "6LcrstkSAAAAAIaBF-lyD5tpCQkqk8Z0uxgfsnRv", :private_key => "6LcrstkSAAAAANnW08PSKQSOiC3r5PfHb02t-0OV-"
    helpers Rack::Recaptcha::Helpers
    enable :sessions

    def initialize(config)
      @config = config
      $config = config
      @cf_target = @config[:cloudfoundry][:cloud_controller_api]
      # this is a variable witch holds the / symbol to be rendered afterwards in css, it is used at breadcrumb navigation
      $slash = '<span class="breadcrumb_slash"> / </span>'

        #use Rack::Recaptcha, :public_key => $config[:recaptcha][:recaptcha_public_key], :private_key => $config[:recaptcha][:recaptcha_private_key]

      # this is the time variable witch will be passed at every page at the bottom
      @time = Time.now
      $this_time = @time.strftime("%m/%d/%Y")
      $path_home = ""

      ChargifyWrapper.configure(config)
      BillingHelper.initialize(config)

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
          redirect '/userLogin'
        end

        if session[:error] == "user exists"
          session[:e_sign_up] = "Email already exists try another one!"
          redirect '/userSignUp'
        end

        if session[:error] == "org create error"
          session[:e_sign_up] = "Server couldn't create the default organization!"
          redirect '/userSignUp'
        end

        if session[:error] == "signup error"
          session[:e_sign_up] = "Server did not respond!"
          redirect '/userSignUp'
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

    # /organizations page errors
        if session[:error] == "create organization failed"
            session[:e_create_organization] = "Create organization failed(try other names)!"
            redirect '/organizationsError'
        end

        if session[:error] == "delete organization failed"
            session[:e_delete_organization] = "You are not authorized to delete this organization!"
            redirect '/organizationsError'
        end

    # /organization(guid) - spaces - page errors
        if session[:error] == "create space failed"
            session[:e_create_space] = "Create space failed(try other names)!"
            redirect '/resetOrganization'
        end

        if session[:error] == "delete space failed"
            session[:e_delete_space] = "You are not authorized to delete this space!"
            redirect '/resetOrganization'
        end

        if session[:error] == "User account doesn't exist-org"
            session[:e_create_user] = "You are not authorized or the user doesn't exist!"
            redirect '/resetOrganization'
        end

        if session[:error] == "User account doesn't exist-space"
            session[:e_create_user] = "You are not authorized or the user doesn't exist!"
            redirect '/resetSpace'
        end

        if session[:error] == "delete user error-org"
            session[:e_delete_user] = "You are not authorized to delete this user!"
            redirect '/resetOrganization'
        end

        if session[:error] == "delete user error-space"
            session[:e_delete_user] = "You are not authorized to delete this user!"
            redirect '/resetSpace'
        end

    # /space(guid) - current space - page errors
        if session[:error] == "create app error"
            session[:e_create_app] = "App was not created: server error!"
            redirect '/resetSpace'
        end

        if session[:error] == "update app error"
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

    get '/userLogin' do
      erb :index, {:locals => {:user_login_failed => session[:temp_user_login]}, :layout => :layout_guest}
    end

    get '/userSignUp' do
      erb :index, {:locals => {:user_failed => session[:temp_username], :first_name_failed => session[:temp_first_name], :last_name_failed => session[:temp_last_name]}, :layout => :layout_guest}
    end


    get '/resetAccount' do
      session[:e_reset_account] = true
      redirect '/account'
    end

    get '/organizationsError' do
      session[:e_reset_organizations] = true
      erb :organizations, {:layout => :layout_user}
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

      if session[:welcome_message] == nil
        redirect '/getDomain'
      end

      session[:login_] = false
      session[:error] = nil

      session[:username] = ""
      session[:e_sign_up] = ""
      session[:e_login] = ""

      session[:temp_username] = ""
      session[:temp_first_name] = ""
      session[:temp_last_name] = ""
      session[:temp_user_login] = ""

      session = []
      @timeNow = $this_time
      @title = 'Uhuru App Cloud'
      $path_1 = ''
      $path_2 = ''
      $user = nil

      erb :index, {:layout => :layout_guest}
    end

    get '/getDomain' do
      $config[:domains].each do |domain|
        if request.env["HTTP_HOST"].to_s == domain["url"]
          session[:welcome_message] = domain["welcome_message"]
          session[:page_title] = domain["page_title"]
          redirect '/'
        end
      end
      redirect '/'
    end

    post '/login' do
      session[:welcome_message] = nil
      session[:page_title] = nil
      if params[:username]
        session[:welcome_message] = nil   # Clears out the page title and the welcome message to avoid server errors
        session[:page_title] = nil        #

        @username = params[:username]
        @password = params[:password]

        session[:temp_user_login] = params[:username]

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
      paramete_email = params[:email]
      paramete_password = params[:password]
      paramete_given_name = params[:first_name]
      paramete_family_name = params[:last_name]

      session[:temp_username] = params[:email]
      session[:temp_first_name] = params[:first_name]
      session[:temp_last_name] = params[:last_name]


      key = $config[:webui][:activation_link_secret]
      email = Encryption.encrypt_text(paramete_email, key)
      pass = Encryption.encrypt_text(paramete_password, key)
      family_name = Encryption.encrypt_text(paramete_family_name, key)
      given_name = Encryption.encrypt_text(paramete_given_name, key)

      user_sign_up = UsersSetup.new(@config)
      user = user_sign_up.signup(paramete_email, $config[:webui][:signup_user_password], paramete_given_name, paramete_family_name)

      link = "http://#{request.env["HTTP_HOST"].to_s}/activate/#{URI.encode(Base32.encode(pass))}/#{URI.encode(Base32.encode(user.guid))}"
      Email::send_email(@email, 'Hello', erb(:email, {:locals =>{:link => link}}))


      ##if recaptcha_valid? then

      #TODO:   --   MAKE RECAPTCH ERRORS

      ##end

      session[:token] = user.token
      session[:fname] = user.first_name
      session[:lname] = user.last_name
      session[:username] = params[:username]
      session[:user_guid] = user.guid
      session[:secret] = session[:session_id]
      session[:login_] = true

      redirect '/pleaseConfirm'
    end

    get '/pleaseConfirm' do
      erb :pleaseConfirm, { :layout => :layout_error }
    end

    get '/activate/:password/:email' do
        password_b32 = Base32.decode(params[:password])
        user_guid_b32 = Base32.decode(params[:email])

        key = $config[:webui][:activation_link_secret]
        user_guid = Encryption.decrypt_text(user_guid_b32, key)
        password = Encryption.decrypt_text(password_b32, key)

        change_password = UsersSetup.new(@config)
        change_password.change_password(user_guid, password, $config[:webui][:signup_user_password])

        redirect "/active"
    end

    get '/active' do
      erb :activation, { :layout => :layout_error }
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

      #this code resets the errors in organizations page # >>
      session[:e_login] = ""
      session[:e_sign_up] = ""
      session[:e_create_organization] = ""
      session[:e_delete_organization] = ""
      session[:e_reset_organizations] = false
      # <<

      @this_user = session[:username]

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
      end
      session[:e_reset_organization] = false
      # <<

      @timeNow = $this_time

      organizations_Obj = Organizations.new(session[:token], @cf_target)
      credit_cards_Obj = CreditCards.new(session[:token], @cf_target)
      users_setup_Obj = UsersSetup.new(@config)
      all_users = users_setup_Obj.uaa_get_usernames

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

      begin
        billing_manager_guid = "58f6e4e9-e4f2-47bb-b8b5-a1629457992d"  # will be billings_list[0].guid
        credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(@this_guid, billing_manager_guid)
      rescue Exception => ex
        credit_card_type = nil
        credit_card_masked_number = nil
        puts "Exception raised for credit card type and masked number!"
        puts ex
      end

      erb :organization, {:locals => {:card_type => credit_card_type, :card_masked_number => credit_card_masked_number, :all_users => all_users, :spaces_list => spaces_list, :spaces_count => spaces_list.count, :members_count => owners_list.count + billings_list.count + auditors_list.count, :owners_list => owners_list, :billings_list => billings_list, :auditors_list => auditors_list}, :layout => :layout_user}
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
      users_setup_Obj = UsersSetup.new(@config)
      all_space_users = users_setup_Obj.uaa_get_usernames

      @this_guid = params[:space_guid]

      session[:space_name] = spaces_Obj.get_name(@this_guid)
      session[:path_2] = $slash + '<a href="/space' + @this_guid + '" class="breadcrumb_element" id="element_space">' + session[:space_name] + '</a>'

      session[:currentSpace] = @this_guid
      session[:currentSpace_Name] = spaces_Obj.get_name(@this_guid)

      spaces_Obj.set_current_space(@this_guid)
      apps_list = spaces_Obj.read_apps(@this_guid)
      services_list = spaces_Obj.read_service_instances(@this_guid)

      owners_list = spaces_Obj.read_owners(@config, session[:currentSpace])
      developers_list = spaces_Obj.read_developers(@config, session[:currentSpace])
      auditors_list = spaces_Obj.read_auditors(@config, session[:currentSpace])

      collections = readapps_Obj.read_collections

      erb :space, {:locals => {:collections => collections, :all_space_users => all_space_users, :owners_list => owners_list, :auditors_list => auditors_list, :users_count => owners_list.count + developers_list.count + auditors_list.count, :developers_list => developers_list, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
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

      @timeNow = $this_time

      session[:path_1] = ''
      session[:path_2] = ''
      $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'


      erb :usersettings, {:layout => :layout_user}
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
      #erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
    end

    post '/stopApp' do
      @name = params[:appName]
      apps_obj = Applications.new(session[:token], @cf_target)

      apps_obj.stop_app(@name)

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
      session[:fname] = @first_name

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



    get '/create_subscription' do

      product_id = "3283746"
      billing_manager_guid = "58f6e4e9-e4f2-47bb-b8b5-a1629457992d"

      users = UsersSetup.new(@config)
      name = users.get_details(session[:user_guid])
      #puts "first name: " + name[:first_name].to_s
      #puts "last name: " + name[:last_name].to_s

      first_name = "Marius"
      last_name = "Test"
      email = session[:username]


      org_guid = session[:currentOrganization]
      reference = "#{billing_manager_guid} #{org_guid}"
      org_name = session[:currentOrganization_Name]

      product_id = "3288276"
      #session[:fname] = @first_name
      product_hosted_page = "https://#{@config[:quota_settings][:billing_provider_domain]}.#{@config[:quota_settings][:billing_provider]}.com/h/#{product_id}/subscriptions/new?first_name=#{first_name}&last_name=#{last_name}&email=#{email}&reference=#{reference}&organization=#{org_name}"

      redirect product_hosted_page
    end

    get '/subscribe_result' do
      customer_reference = params[:ref]

      # credit_card_masked_number = "XXXX-XXXX-XXXX-1" and credit_card_type = "bogus" while chargify account is in test
      # is not known what the other credit card types are. For credit card masked number suppose the group after last -
      # which now is 1 will represent last four number from a real credit card.

      # this is only an example how to read credit card info for an organizations, having organization guid and billing manager guid
      # first parameter is organization guid and the second parameter is the billing manager guid which can be only one

      #credit_card_type , credit_card_masked_number = ChargifyWrapper.get_subscription_card_type_and_number(org_gui, billing_manager_guid)


      # this is only to see how make_organization_billable works, to be moved in the right place
      org_guid = customer_reference.last(36).to_s
      if (ChargifyWrapper.subscription_exists?(customer_reference))
        org = Organizations.new(session[:token], @cf_target)
        org.make_organization_billable(org_guid)
      end


      #org_guid = "2cfeb438-e804-4303-8637-476d7cdd6889" #session[:currentOrganization]
      org_name = org.get_name(org_guid)

      erb :subscribe_result, {:locals => {:org_name => org_name, :org_guid => org_guid}, :layout => :layout_user}
    end

  end
end

#     THIS IS THE SAMPLE CODE FOR ITERATE THE FILES AND FOLDERS FROM TEMPLATE _ APPS


#collections["collections"].each do |collection|
#  collection_details = readapps_Obj.read_collection(collection["collection"]["folder"])
#
#  if collection_details != nil
#    app_folders = Array.new
#    read_folders = Dir.foreach("../template_apps/" + collection["collection"]["folder"])
#
#
#    read_folders.each do |this_folder|
#      if this_folder != "." && this_folder != ".." && this_folder != "template_collection_manifest.yml" && this_folder != "template_collection_logo.png"
#          app_folders.push this_folder
#      end
#    end
#
#    puts "APP FOLDERS " + app_folders.to_s
#
#    if app_folders != nil
#      app_folders.each do |app_folder|
#
#        puts "collection folder " + collection["collection"]["folder"]
#        puts "app folder " + app_folder
#
#        app_details = readapps_Obj.read_apps(collection["collection"]["folder"], app_folder)
#
#        if app_details != nil
#          puts app_details["name"]
#        end
#      end
#    end
#  end
#end

