$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'yaml'
require 'uhuru_config'
require 'dev_utils'
require 'date'
require 'readapps'

UhuruConfig.load

set :port, UhuruConfig.uhuru_webui_port



$space_name = 'breadcrumb space'                              #this variable will be shown at breadcrumb navigation
$organization_name = 'breadcrumb org'                         #this variable will be shown at breadcrumb navigation

$path_1                                                       #this is an empty string that will take the value of $organization_name
$path_2                                                       #this is an empty string that will take the value of $space_name
$path_home                                                    #= <a href="/organizations" class="breadcrumb_element_home">Organizations:</a>

$currentOrganization                                          #this is the Organization Guid for the current space on the website
$currentSpace                                                 #this is the Space Guid for the current apps, services and subscriptions on the website

$currentOrganization_Name                                     #this is the Organization NAME STRING for the current space on the website
$currentSpace_Name                                            #this is the Space NAME STRING for the current space on the website

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

#user = UsersSetup.new
#
##user.add_user('adelyna@gmail.com', 'pass', 'a', 's')
#user.get_user_token('adelyna@gmail.com', 'pass')

get'/' do
  @timeNow = $this_time
  @title = 'Uhuru App Cloud'

  $path_1 = ''
  $path_2 = ''


  erb :index, {:layout => :layout_guest }
end


post '/login' do
  @username = params[:username]
  @password = params[:password]

  user_login = UsersSetup.new
  $user_token = user_login.get_user_token(@username, @password)

  redirect '/organizations'

end

post '/signup' do
  @email = params[:email]
  @password = params[:password]
  @given_name = params[:first_name]
  @family_name = params[:last_name]

  user_sign_up = UsersSetup.new
  $user = user_sign_up.add_user(@email, @password, @given_name, @family_name)
  $user_token = user_sign_up.get_user_token(@email, @password)

  redirect '/organizations'

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
  @usertitle = "User" + " " + "Uhuru"
  @timeNow = $this_time

  $path_1 = ''
  $path_2 = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'

  organizations_Obj = Organizations.new(user_token)
  organizations_list = organizations_Obj.read_all

  $currentOrganization = nil
  $currentSpace = nil

  erb :organizations, {:locals => {:organizations_list => organizations_list, :organizations_count => organizations_list.count}, :layout => :layout_user}
end


get'/credit' do
  @usertitle = "User" + " " + "Uhuru"
  @timeNow = $this_time

  $path_1 = ''
  $path_2 = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home"></a>'

  erb :creditcard, {:layout => :layout_user}
end






get'/organization:org_guid' do
  @timeNow = $this_time

  organizations_Obj = Organizations.new(user_token)

  @this_guid = params[:org_guid]
  $organization_name = organizations_Obj.get_name(@this_guid)
  $path_1 = $slash + '<a href="/organization' + @this_guid + ' "class="breadcrumb_element" id="element_organization">' + $organization_name + '</a>'
  $path_2 = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home">ORGANIZATIONS</a>'

  $currentOrganization = @this_guid
  $currentOrganization_Name = organizations_Obj.get_name(@this_guid)
  $currentSpace = nil

  organizations_Obj.set_current_org(@this_guid)
  spaces_list = organizations_Obj.read_spaces(@this_guid)
  owners_list = organizations_Obj.read_owners(@this_guid)
  developers_list = organizations_Obj.read_developers(@this_guid)
  managers_list = organizations_Obj.read_managers(@this_guid)


  erb :organization, {:locals => {:spaces_list => spaces_list, :spaces_count => spaces_list.count, :members_count => owners_list.count + developers_list.count + managers_list.count, :owners_list => owners_list, :developers_list => developers_list, :managers_list => managers_list}, :layout => :layout_user}
end



get'/space:space_guid' do
  @timeNow = $this_time

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)
  readapps_Obj = TemplateApps.new

  @this_guid = params[:space_guid]

  $space_name = spaces_Obj.get_name(@this_guid)
  $path_2 = $slash + '<a href="/space' + @this_guid + '" class="breadcrumb_element" id="element_space">' + $space_name + '</a>'
  $path_home = '<a href="/organizations" class="breadcrumb_element_home">ORGANIZATIONS</a>'

#  $currentOrganization = nil
  $currentSpace = @this_guid
  $currentSpace_Name = spaces_Obj.get_name(@this_guid)

  spaces_Obj.set_current_space(@this_guid)
  apps_list = spaces_Obj.read_apps(@this_guid)
  services_list = spaces_Obj.read_service_instances(@this_guid)

  apps_names = readapps_Obj.read_apps

  erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
end


post '/createOrganization' do
  @name = params[:orgName]
  @organization_message = "Creating organization... Please wait"

  organizations_Obj = Organizations.new(user_token)
  organizations_Obj.create(@name)
  redirect "/organizations"
end

post '/createSpace' do
  @name = params[:spaceName]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)

  spaces_Obj.create($currentOrganization, @name)
  redirect "/organization" + $currentOrganization
end

post '/updateOrganization' do
  @name = params[:m_organizationName]
  organizations_Obj = Organizations.new(user_token)
  organizations_Obj.update(@name, $currentOrganization)
  redirect "/organization" + $currentOrganization
end

post '/deleteCurrentOrganization' do
  organizations_Obj = Organizations.new(user_token)
  organizations_Obj.delete($currentOrganization)
  redirect "/organizations"
end

post '/deleteClickedOrganization' do
  @guid = params[:orgGuid]

  organizations_Obj = Organizations.new(user_token)
  organizations_Obj.delete(@guid)
  redirect "/organizations"
end

post '/updateSpace' do
  @name = params[:m_spaceName]
  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)

  spaces_Obj.update(@name, $currentSpace)
  redirect "/space" + $currentSpace
end

post '/deleteCurrentSpace' do
  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)
  spaces_Obj.delete($currentSpace)
  redirect "/organization" + $currentOrganization
end

post '/deleteClickedSpace' do
  @guid = params[:spaceGuid]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)

  spaces_Obj.delete(@guid)
  redirect "/organization" + $currentOrganization
end

post '/deleteClickedApp' do
  @guid = params[:appGuid]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)
  applications_Obj = Applications.new(user_token)

  applications_Obj.delete(@guid)
  redirect "/space" + $currentSpace
end

post '/deleteClickedService' do
  @guid = params[:serviceGuid]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)
  applications_Obj = Applications.new(user_token)
  services_Obj = ServiceInstances.new(user_token)

  services_Obj.delete(@guid)

  redirect "/space" + $currentSpace
end


post '/createApp' do
  @name =  params[:appName]
  @runtime = params[:appRuntime]
  @framework = params[:appFramework]
  @instance = 1
  @memory = params[:appMemory]

  @domain = "ccng-dev.net"
  @path = "/home/ubuntu/Desktop/rubytest"

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)
  apps_obj = Applications.new(user_token)


  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  apps_obj.create($currentOrganization, $currentSpace, @name, @runtime, @framework, @instance, @memory.to_i, @domain, @path, @plan)
  redirect "/space" + $currentSpace
end


post '/createService' do
  @name = params[:serviceName]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = ServiceInstances.new(user_token)

  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  spaces_Obj.create_service_instance(@name, $currentSpace, @plan)

  redirect "/space" + $currentSpace
end


post '/addUsers' do
  @email =  params[:userEmail]
  @type = params[:userType]

  organizations_Obj = Organizations.new(user_token)
  users_Obj = Users.new(user_token)
  users_Obj.add_user_to_org_with_role($currentOrganization, @name, @type)


  redirect "/organization" + $currentOrganization
end




post '/startApp' do
  @name = params[:appName]
  apps_obj = Applications.new(user_token)

  apps_obj.start_app(@name)
  puts @name

  redirect "/space" + $currentSpace
  erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
end

post '/stopApp' do
  @name = params[:appName]
  apps_obj = Applications.new(user_token)

  apps_obj.stop_app(@name)
  puts @name

  redirect "/space" + $currentSpace
end



post '/updateApp' do
  @name = params[:appName]
  @memory = params[:appMemory]
  @instances = params[:appInstances]

  apps_obj = Applications.new(user_token)
  apps_obj.update(@name, @instances, @memory)

  redirect "/spaces" + $currentSpace
end



post '/bindServices' do
  @app_name = params[:appName]
  @service_name = params[:serviceName]

  apps = Applications.new(user_token)
  apps.bind_app_services(@app_name, @service_name)

  redirect "/space" + $currentSpace
end


post '/unbindServices' do
  @app_name = params[:appName]
  @service_name = params[:serviceName]

  apps = Applications.new(user_token)
  apps.unbind_app_services(@app_name, @service_name)

  redirect "/space" + $currentSpace
end


post '/bindUri' do
  @app_name = params[:appName]
  @uri_name = params[:uriName]
  @domain_name = "api3.ccng-dev.net"

  apps = Applications.new(user_token)
  apps.bind_app_url(@app_name, $currentOrganization, @domain_name, @uri_name)

  redirect "/space" + $currentSpace
end


post '/unbindUri' do
  @app_name = params[:appName]
  @uri_name = params[:uriName]
  @domain_name = "http://api3.ccng-dev.net"

  apps = Applications.new(user_token)
  apps.unbind_app_url(@app_name, @domain_name, @uri_name)

  redirect "/space" + $currentSpace
end







