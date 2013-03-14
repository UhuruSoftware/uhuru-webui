require 'yaml'
require 'config'
require 'dev_utils'
require 'date'
require 'sinatra/session'
require 'profiler'

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
      @cf_target = @config[:cloud_controller_url]
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







    get '/infopage' do
      @title = "Uhuru Info"
      @timeNow = $this_time

      $path_1 = ''
      $path_2 = ''

      erb :infopage, {:layout => :layout_infopage}
    end

    get '/organization:org_guid' do

      if session[:login_] == false
        redirect '/'
      end

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



    get '/tapps/zip/:file' do |file|

      file = File.join('../tapps/zip/wordpress.zip', file)
      send_file(file, :disposition => 'attachment', :filename => File.basename(file))

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

