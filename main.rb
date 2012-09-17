$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'uhuru_config'
require 'dev_utils'

UhuruConfig.load

set :port, UhuruConfig.uhuru_webui_port

$space_name = 'breadcrumb space'
$organization_name = 'breadcrumb org'
$path_1
$path_2
$slash = '<span class="breadcrumb_slash"> / </span>'

def user_token
  if (UhuruConfig.dev_mode)
    DevUtils.test_token
  else
    ''
  end
end

get'/' do
  @time = Time.now
  @timeNow = @time.inspect
  @title = 'Uhuru App Cloud'

  $path_1 = ''
  $path_2 = ''

  erb :index, {:layout => :layout_guest}
end


get'/infopage' do
  @title = "Uhuru Info"
  @time = Time.now
  @timeNow = @time.inspect

  $path_1 = ''
  $path_2 = ''

  erb :infopage, {:layout => :layout_infopage}
end


get'/organizations' do
  @usertitle = "User" + " " + "Uhuru"
  @time = Time.now
  @timeNow = @time.inspect

  $path_1 = ''
  $path_2 = ''

  organizations = Organizations.new(user_token)
  organizations_list = organizations.readAll

  erb :organizations, {:locals => {:organizations_list => organizations_list, :organizations_count => organizations_list.count}, :layout => :layout_user}
end


get'/organization/:org_guid' do
  @time = Time.now
  @timeNow = @time.inspect
  @spc_name = 'Ruby space'

  $path_1 = $slash + '<a href="/organization" class="breadcrumb_element">' + $organization_name + '</a>'
  $path_2 = ''

  erb :organization, {:layout => :layout_user}
end

get'/space' do
  @time = Time.now
  @timeNow = @time.inspect

  $path_2 = $slash + '<a href="/space" class="breadcrumb_element">' + $space_name + '</a>'

  erb :space, {:layout => :layout_user}
end






get'/modal_createapp' do
  @time = Time.now
  @timeNow = @time.inspect
  erb :modal_createapp, {:layout => :layout_user}
end

  #testing links between views
get'/test' do
  erb :test, {:layout => :layout_user}
end


  #testing variables passed between views
get '/test' do
  @message = "apare pe pagina"
  erb :test, {:layout => :layout_user }
end