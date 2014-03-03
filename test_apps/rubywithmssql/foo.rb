require 'rubygems'
require 'sinatra'
require 'json'


get '/' do
  obj = JSON.parse(ENV['VCAP_SERVICES'])
  credentials = obj['mssql-2008'][0]['credentials']
  output = "#{obj.inspect}"
  begin
#    redis = Redis.new( :host => credentials["host"],
#                       :port => credentials["port"],
#                       :password => credentials["password"],
#                       :db => "salam") #credentials["name"] )
    "<h3>#{output.to_s}</h1>"
  rescue => e
    "#{e.message} #{e.backtrace}"
    raise e
  end

end

