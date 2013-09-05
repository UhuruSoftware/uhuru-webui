require 'rubygems'
require 'sinatra'
require 'mysql'
require 'json'


get '/' do
    obj = JSON.parse(ENV['VCAP_SERVICES'])
	credentials = obj['mysql-5.1'][0]['credentials']
	
	#my = Mysql.new(hostname, username, password, databasename)  
	con = Mysql.new(credentials['hostname'], credentials['user'], credentials['password'], credentials['name']) 
	puts 'success'
	
end
