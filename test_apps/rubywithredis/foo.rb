require 'rubygems'
require 'sinatra'
require 'redis'
require 'json'


get '/' do
  obj = JSON.parse(ENV['VCAP_SERVICES'])
  credentials = obj['redis-2.6'][0]['credentials']
  output = ""
  begin
    redis = Redis.new( :host => credentials["host"],
                       :port => credentials["port"],
                       :password => credentials["password"],
                       :db => "salam") #credentials["name"] )
    redis.set "foo", "Success"    
    output = redis.get "foo"
    "<h3>#{output.to_s}</h1>"
  rescue => e
    "#{e.message} #{e.backtrace}"
    raise e
  end

end

