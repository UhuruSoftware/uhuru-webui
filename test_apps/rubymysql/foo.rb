require 'rubygems'
require 'sinatra'
require 'mysql'
require 'json'

get '/' do
  obj = JSON.parse(ENV['VCAP_SERVICES'])
  credentials = obj['mysql-5.5'][0]['credentials']  
  
  begin
    con = Mysql.new(credentials['hostname'], credentials['user'], credentials['password'], credentials['name'], credentials['port']) 
    "<h3>Success</h1>"
  rescue => e
    "#{e.message} #{e.backtrace}"
  end  

end
