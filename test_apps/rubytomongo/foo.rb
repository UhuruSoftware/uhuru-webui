require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'


get '/' do
    obj = JSON.parse(ENV['VCAP_SERVICES'])
		
	credentials = obj['mongodb-2.0'][0]['credentials']
		
	con = Mongo::Connection.new(credentials['host'], credentials['port']).db(credentials['name'])
	puts 'success'
	
end


