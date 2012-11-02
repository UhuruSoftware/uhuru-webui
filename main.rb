$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'yaml'
require 'uhuru_config'
require 'dev_utils'
require 'date'
require 'sinatra/session'

UhuruConfig.load

set :port, UhuruConfig.uhuru_webui_port

#session[:space_name] = 'breadcrumb space'                              #this variable will be shown at breadcrumb navigation
#session[:organization_name] = 'breadcrumb org'                         #this variable will be shown at breadcrumb navigation

$path_home                                                    #= <a href="/organizations" class="breadcrumb_element_home">Organizations:</a>

#$currentOrganization                                          #this is the Organization Guid for the current space on the website
#$currentSpace                                                 #this is the Space Guid for the current apps, services and subscriptions on the website

#session[:currentOrganization_Name]                                     #this is the Organization NAME STRING for the current space on the website
#session[:currentSpace_Name]                                            #this is the Space NAME STRING for the current space on the website

set :session_fail, '/login'
set :session_secret, 'secret!'


$slash = '<span class="breadcrumb_slash"> / </span>'          #this is a variable witch holds the / symbol to be rendered afterwards in css, it is used at breadcrumb navigation

@time = Time.now                                              #
$this_time = @time.strftime("%m/%d/%Y")                       # this is the time variable witch will be passed at every page at the bottom
                                                              #

$user_token

def user_token
  if (UhuruConfig.dev_mode)
    #DevUtils.test_token
    $user_token
  else
    $user_token
  end
end


get '/' do
  @timeNow = $this_time
  @title = 'Uhuru App Cloud'
  $path_1 = ''
  $path_2 = ''

  $user = nil

  erb :index, {:layout => :layout_guest }
end


get '/login' do
  if session?
    redirect '/organizations'
  else
    redirect '/'
  end
end

post '/login' do
  if params[:username]
    session_start!

    @username = params[:username]
    @password = params[:password]

    user_login = UsersSetup.new
    user = user_login.login(@username, @password)
    session[:token] = user.token

    session[:fname] = user.first_name + ' ' + user.last_name
    session[:username] = params[:username]

    puts session[:token]
    redirect '/organizations'
  else
    redirect '/'
  end
end


get '/logout' do
  session_end!(destroy=true)
  redirect '/'
end



post '/signup' do
  @email = params[:email]
  @password = params[:password]
  @given_name = params[:first_name]
  @family_name = params[:last_name]

  user_sign_up = UsersSetup.new
  user_sign_up.signup(@email, @password, @given_name, @family_name)

  redirect '/'
end




get'/infopage' do
  @title = "Uhuru Info"
  @timeNow = $this_time

  $path_1 = ''
  $path_2 = ''

  erb :infopage, {:layout => :layout_infopage }
end


                  #  --- READ ---  #

get'/organizations' do
  session!
  @this_user = session[:username]

  @usertitle = @this_user
  @timeNow = $this_time

  session[:path_1] = ''
  session[:path_2] = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'

  organizations_Obj = Organizations.new(session[:token])
  organizations_list = organizations_Obj.read_all

  session[:currentOrganization] = nil
  session[:currentSpace] = nil

  erb :organizations, {:locals => {:organizations_list => organizations_list, :organizations_count => organizations_list.count}, :layout => :layout_user}
end


get'/credit' do
  session!
  @usertitle = session[:username]
  @timeNow = $this_time

  session[:path_1] = ''
  session[:path_2] = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'

  my_credit_cards = nil

  erb :creditcard, {:locals => {:my_credit_cards => my_credit_cards}, :layout => :layout_user}
end


get'/account' do
  session!
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


  @cvv = params[:cvv]
  @address1 = params[:address1]
  @address2 = params[:address2]


  @city = params[:city]
  #@state = params[:state]
  #@zip = params[:zip]
  @country = params[:country]

  @card_type = params[:card_type]

  credit_cards_Obj = CreditCards.new(session[:token])
  new_credit_card = nil # credit_cards_Obj.create($currentOrganization, firs_name, last_name, card_number, expiration_year, expiration_month,
                        #cvv, address1, address2, city, state, zip, country, card_type )


  puts "first name" + @first_name + "\n"
  puts "last name" + @last_name + "\n"
  puts "card nr" + @card_number + "\n"
  puts "year" + @expiration_year + "\n"
  puts "month" + @expiration_month + "\n"


  puts "cvv" + @cvv + "\n"
  puts "add1" + @address1 + "\n"
  puts "add2" + @address2 + "\n"


  puts "city" + @city + "\n"
  #puts "state" + @state + "\n"
  #puts "zip" + @zip + "\n"
  puts "country" + @country + "\n"


  puts "card type : " + @card_type + "\n"



  redirect "/credit"
end





get'/organization:org_guid' do
  session!

  @timeNow = $this_time

  organizations_Obj = Organizations.new(session[:token])
  credit_cards_Obj = CreditCards.new(session[:token])

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
  owners_list = organizations_Obj.read_owners(@this_guid)
  developers_list = organizations_Obj.read_developers(@this_guid)
  managers_list = organizations_Obj.read_managers(@this_guid)


  credit_cards_list = nil # credit_cards_Obj.read_all($currentOrganization)


  erb :organization, {:locals => {:credit_cards_list => credit_cards_list, :spaces_list => spaces_list, :spaces_count => spaces_list.count, :members_count => owners_list.count + developers_list.count + managers_list.count, :owners_list => owners_list, :developers_list => developers_list, :managers_list => managers_list}, :layout => :layout_user}
end



get'/space:space_guid' do
  session!

  @timeNow = $this_time

  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])
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

  erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
end







post '/createOrganization' do
  @name = params[:orgName]
  @organization_message = "Creating organization... Please wait"

  organizations_Obj = Organizations.new(session[:token])
  organizations_Obj.create(@name)
  redirect "/organizations"
end

post '/createSpace' do
  @name = params[:spaceName]

  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])

  spaces_Obj.create(session[:currentOrganization], @name)
  redirect "/organization" + session[:currentOrganization]
end

post '/updateOrganization' do
  @name = params[:m_organizationName]
  organizations_Obj = Organizations.new(session[:token])
  organizations_Obj.update(@name, session[:currentOrganization])
  redirect "/organization" + session[:currentOrganization]
end

post '/deleteCurrentOrganization' do
  organizations_Obj = Organizations.new(session[:token])
  organizations_Obj.delete(session[:currentOrganization])
  redirect "/organizations"
end

post '/deleteClickedOrganization' do
  @guid = params[:orgGuid]

  organizations_Obj = Organizations.new(session[:token])
  organizations_Obj.delete(@guid)
  redirect "/organizations"
end

post '/updateSpace' do
  @name = params[:m_spaceName]
  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])

  spaces_Obj.update(@name, session[:currentSpace])
  redirect "/space" + session[:currentSpace]
end

post '/deleteCurrentSpace' do
  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])
  spaces_Obj.delete(session[:currentSpace])
  redirect "/organization" + session[:currentOrganization]
end

post '/deleteClickedSpace' do
  @guid = params[:spaceGuid]
  puts @guid
  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])

  spaces_Obj.delete(@guid)
  redirect "/organization" + session[:currentOrganization]
end

post '/deleteClickedApp' do
  @guid = params[:appGuid]

  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])
  applications_Obj = Applications.new(session[:token])

  applications_Obj.delete(@guid)
  redirect "/space" + session[:currentSpace]
end

post '/deleteClickedService' do
  @guid = params[:serviceGuid]

  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])
  applications_Obj = Applications.new(session[:token])
  services_Obj = ServiceInstances.new(session[:token])

  services_Obj.delete(@guid)

  redirect "/space" + session[:currentSpace]
end


post '/createApp' do
  @name =  params[:appName]
  @runtime = params[:appRuntime]
  @framework = params[:appFramework]
  @instance = 1
  @memory = params[:appMemory]

  @domain = "ccng-dev.net"
  @path = "/home/ubuntu/Desktop/rubytest"

  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = Spaces.new(session[:token])
  apps_obj = Applications.new(session[:token])


  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  apps_obj.create(session[:currentOrganization], session[:currentSpace], @name, @runtime, @framework, @instance, @memory.to_i, @domain, @path, @plan)
  redirect "/space" + session[:currentSpace]
end


post '/createService' do
  @name = params[:serviceName]

  organizations_Obj = Organizations.new(session[:token])
  spaces_Obj = ServiceInstances.new(session[:token])

  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  spaces_Obj.create_service_instance(@name, session[:currentSpace], @plan)

  redirect "/space" + session[:currentSpace]
end


post '/addUsers' do
  @email =  params[:userEmail]
  @type = params[:userType]

  organizations_Obj = Organizations.new(session[:token])
  users_Obj = Users.new(session[:token])
  users_Obj.add_user_with_role_to_space(session[:currentOrganization], @name, @type)


  redirect "/organization" + session[:currentOrganization]
end




post '/startApp' do
  @name = params[:appName]
  apps_obj = Applications.new(session[:token])

  apps_obj.start_app(@name)
  puts @name

  redirect "/space" + session[:currentSpace]
  erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
end

post '/stopApp' do
  @name = params[:appName]
  apps_obj = Applications.new(session[:token])

  apps_obj.stop_app(@name)
  puts @name

  redirect "/space" + session[:currentSpace]
end



post '/updateApp' do
  @name = params[:appName]
  @memory = params[:appMemory]
  @instances = params[:appInstances]

  apps_obj = Applications.new(session[:token])
  apps_obj.update(@name, @instances, @memory)

  redirect "/spaces" + session[:currentSpace]
end



post '/bindServices' do
  @app_name = params[:appName]
  @service_name = params[:serviceName]

  apps = Applications.new(session[:token])
  apps.bind_app_services(@app_name, @service_name)

  redirect "/space" + session[:currentSpace]
end


post '/unbindServices' do
  @app_name = params[:appName]
  @service_name = params[:serviceName]

  apps = Applications.new(session[:token])
  apps.unbind_app_services(@app_name, @service_name)

  redirect "/space" + session[:currentSpace]
end


post '/bindUri' do
  @app_name = params[:appName]
  @uri_name = params[:uriName]
  @domain_name = "api3.ccng-dev.net"

  apps = Applications.new(session[:token])
  apps.bind_app_url(@app_name, session[:currentOrganization], @domain_name, @uri_name)

  redirect "/space" + session[:currentSpace]
end


post '/unbindUri' do
  @app_name = params[:appName]
  @uri_name = params[:uriName]
  @domain_name = "http://api3.ccng-dev.net"

  apps = Applications.new(session[:token])
  apps.unbind_app_url(@app_name, @domain_name, @uri_name)

  redirect "/space" + session[:currentSpace]
end


post '/updateUser' do
  @first_name = params[:first_name]
  @last_name = params[:last_name]
  @password = params[:pass1]

  puts @first_name + "\n" + @last_name + "\n" + @password

end

