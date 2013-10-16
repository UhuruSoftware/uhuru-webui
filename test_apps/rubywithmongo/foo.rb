require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'

get '/' do
  obj = JSON.parse(ENV['VCAP_SERVICES'])
  credentials = obj['mongodb-2.0'][0]['credentials']

  begin
    con = Mongo::Connection.new(credentials['host'], credentials['port']).db(credentials['name'])
    "<h3>Success</h1>"
  rescue => e
    "#{e.message} #{e.backtrace}"
  end
  
end

