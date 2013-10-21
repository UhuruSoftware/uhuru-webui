require 'rubygems'
require 'sinatra'
require 'pg'
require 'json'


get '/' do
  obj = JSON.parse(ENV['VCAP_SERVICES'])
  credentials = obj['postgresql-9.2'][0]['credentials']
  output = ""
  begin
    conn = PGconn.connect( :dbname => credentials["name"],
                          :port => credentials["port"],
                          :host => credentials["host"],
                          :user => credentials["user"],
                          :password => credentials["password"] )
    
    "<h3>Success</h1>"
  rescue => e
    "#{e.message} #{e.backtrace}"
    raise e
  end

end

