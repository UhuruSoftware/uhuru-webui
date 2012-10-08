$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
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

def user_token
  if (UhuruConfig.dev_mode)
    DevUtils.test_token
  else
    ''
  end
end

space = Spaces.new(user_token)
space.read_apps("77a16804-bc5b-4482-9ae4-f6a62cfb7af8")

get'/' do
  @timeNow = $this_time
  @title = 'Uhuru App Cloud'

  $path_1 = ''
  $path_2 = ''

  erb :index, {:layout => :layout_guest}
end


get'/infopage' do
  @title = "Uhuru Info"
  @timeNow = $this_time

  $path_1 = ''
  $path_2 = ''

  erb :infopage, {:layout => :layout_infopage}
end


                  #  --- READ ---  #

get'/organizations' do
  @usertitle = "User" + " " + "Uhuru"
  @timeNow = $this_time

  $path_1 = ''
  $path_2 = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home">Organizations:</a>'

  organizations_Obj = Organizations.new(user_token)
  organizations_list = organizations_Obj.read_all

  $currentOrganization = nil
  $currentSpace = nil

  erb :organizations, {:locals => {:organizations_list => organizations_list, :organizations_count => organizations_list.count}, :layout => :layout_user}
end


get'/organization:org_guid' do
  @timeNow = $this_time

  organizations_Obj = Organizations.new(user_token)

  @this_guid = params[:org_guid]
  $organization_name = organizations_Obj.get_name(@this_guid)
  $path_1 = $slash + '<a href="/organization' + @this_guid + ' "class="breadcrumb_element" id="element_organization">' + $organization_name + '</a>'
  $path_2 = ''
  $path_home = '<a href="/organizations" class="breadcrumb_element_home">Organizations:</a>'

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
  $path_home = '<a href="/organizations" class="breadcrumb_element_home">Organizations:</a>'

#  $currentOrganization = nil
  $currentSpace = @this_guid
  $currentSpace_Name = spaces_Obj.get_name(@this_guid)

  spaces_Obj.set_current_space(@this_guid)
  apps_list = spaces_Obj.read_apps(@this_guid)
  services_list = spaces_Obj.read_service_instances(@this_guid)

  apps_names = readapps_Obj.read_apps

  erb :space, {:locals => {:apps_names => apps_names, :apps_list => apps_list, :services_list => services_list, :apps_count => apps_list.count, :services_count => services_list.count}, :layout => :layout_user}
end


          # --- CREATE --- UPDATE --- DELETE ---        ORGANIZATIONS AND SPACES #


post '/createOrganization' do
  @name = params[:orgName]
  @organization_message = "Creating organization... Please wait"

  organizations_Obj = Organizations.new(user_token)
  organizations_Obj.create(@name)
  redirect "/organizations"
end

post '/createSpace' do
  @name = params[:spaceName]
  @message = "Creating space... Please wait"

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
  @message = "Deleting organization... Please wait"

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
  @message = "Deleting organization... Please wait"

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)

  spaces_Obj.delete(@guid)
  redirect "/organization" + $currentOrganization
end

post '/deleteClickedApp' do
  @guid = params[:appGuid]
  @message = "Deleting app... Please wait"

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)
  applications_Obj = Applications.new(user_token)

  applications_Obj.delete(@guid)
  redirect "/space" + $currentSpace
end

post '/deleteClickedService' do
  @guid = params[:serviceGuid]
  @message = "Deleting service... Please wait"

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
  #spaces_obj = ServiceInstances.new(user_token)


  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  apps_obj.create($currentOrganization, $currentSpace, @name, "ruby19", "sinatra", @instance, 128, @domain, @path, @plan)
  #apps_obj.bind_app_services(@name, @name + "DB")
  redirect "/space" + $currentSpace
end


post '/createService' do
  @name = params[:serviceName]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = ServiceInstances.new(user_token)

  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  spaces_Obj.create_service_instance(@name, $currentSpace, @plan)

  redirect "/spaces" + $currentSpace
end


post '/addUsers' do
  @email =  params[:userEmail]
  @type = params[:userType]

  organizations_Obj = Organizations.new(user_token)
  users_Obj = Users.new(user_token)

  users_Obj.create_user_add_to_org($currentOrganization, @email)

  puts $currentOrganization + "--- ORG"
  puts @email + "--- email"
  puts @type + "--- type"

  redirect "/organization" + $currentOrganization
end




post '/startApp' do
  @name = params[:appName]
  apps_obj = Applications.new(user_token)
  puts "starting app"
  apps_obj.start_app(@name)
  puts "start app COMPLETE"

  redirect "/space" + $currentSpace
end

post '/stopApp' do
  @name = params[:appName]
  apps_obj = Applications.new(user_token)
  puts "stoping app"
  apps_obj.stop_app(@name)
  puts "stoping app COMPLETE"

  redirect "/space" + $currentSpace
end






####test####

post '/test' do
  @name = params[:serviceName]

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = ServiceInstances.new(user_token)

  @plan = "d85b0ad5-02d3-49e7-8bcb-19057a847bf7"

  spaces_Obj.create_service_instance(@name, $currentSpace, @plan)

  redirect "/spaces" + $currentSpace
end

