$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'uhuru_config'
require 'dev_utils'
require 'date'

UhuruConfig.load

set :port, UhuruConfig.uhuru_webui_port



$space_name = 'breadcrumb space'                              #this variable will be shown at breadcrumb navigation
$organization_name = 'breadcrumb org'                         #this variable will be shown at breadcrumb navigation

$path_1                                                       #this is an empty string that will take the value of $organization_name
$path_2                                                       #this is an empty string that will take the value of $space_name

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

  $currentOrganization = @this_guid
  $currentOrganization_Name = organizations_Obj.get_name(@this_guid)
  $currentSpace = nil

  spaces_list = organizations_Obj.read_spaces(@this_guid)
  owners_list = organizations_Obj.read_owners(@this_guid)
  developers_list = organizations_Obj.read_developers(@this_guid)
  managers_list = organizations_Obj.read_managers(@this_guid)

  erb :organization, {:locals => {:spaces_list => spaces_list, :owners_list => owners_list, :developers_list => developers_list, :managers_list => managers_list}, :layout => :layout_user}
end



get'/space:space_guid' do
  @timeNow = $this_time

  organizations_Obj = Organizations.new(user_token)
  spaces_Obj = Spaces.new(user_token)

  @this_guid = params[:space_guid]
  $space_name = spaces_Obj.get_name(@this_guid)
  $path_2 = $slash + '<a href="/space' + @this_guid + '" class="breadcrumb_element" id="element_space">' + $space_name + '</a>'

#  $currentOrganization = nil
  $currentSpace = @this_guid
  $currentSpace_Name = spaces_Obj.get_name(@this_guid)

  apps_list = spaces_Obj.read_apps(@this_guid)
  services_list = spaces_Obj.read_service_instances(@this_guid)

  erb :space, {:locals => {:apps_list => apps_list, :services_list => services_list}, :layout => :layout_user}
end


          # --- CREATE --- UPDATE --- DELETE ---   #


post '/createOrganization' do
  @name = params[:orgName]
  @message = "Creating organization... Please wait"

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
  redirect "/organizations"
end
