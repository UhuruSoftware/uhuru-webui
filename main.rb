$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'uhuru_config'
require 'dev_utils'
require 'date'

UhuruConfig.load

set :port, UhuruConfig.uhuru_webui_port



$space_name = 'breadcrumb space'
$organization_name = 'breadcrumb org'

$path_1
$path_2

$slash = '<span class="breadcrumb_slash"> / </span>'

@time = Time.now
$this_time = @time.strftime("%m/%d/%Y")


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


###################################################################################################

get'/organizations' do
  @usertitle = "User" + " " + "Uhuru"
  @timeNow = $this_time

  $path_1 = ''
  $path_2 = ''

  organizations_Obj = Organizations.new(user_token)
  organizations_list = organizations_Obj.read_all

  erb :organizations, {:locals => {:organizations_list => organizations_list, :organizations_count => organizations_list.count}, :layout => :layout_user}
end





get'/organization:org_guid' do
  @timeNow = $this_time

  organizations_Obj = Organizations.new(user_token)

  @this_guid = params[:org_guid]
  $organization_name = organizations_Obj.get_name(@this_guid)
  $path_1 = $slash + '<a href="/organization" class="breadcrumb_element">' + $organization_name + '</a>'
  $path_2 = ''

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
  $path_2 = $slash + '<a href="/space" class="breadcrumb_element">' + $space_name + '</a>'

  apps_list = spaces_Obj.readApps(@this_guid)
  services_list = spaces_Obj.read_service_instances(@this_guid)

  erb :space, {:locals => {:apps_list => apps_list, :services_list => services_list}, :layout => :layout_user}
end


