require 'rubygems'
require 'sinatra'
require 'amqp'
require 'json'


get '/' do
  obj = JSON.parse(ENV['VCAP_SERVICES'])
  credentials = obj['rabbitmq-3.0'][0]['credentials']
  output = ""
  begin
  EventMachine.run do
    connection = AMQP.connect( :vhost => credentials["vhost"],
                               :port => credentials["port"],
                               :host => credentials["host"],
                               :username => credentials["username"],
                              :password => credentials["password"] )
 
   ch  = AMQP::Channel.new(connection)
   q   = ch.queue("amqpgem.examples.hello_world", :auto_delete => true)
   x   = ch.default_exchange
   q.subscribe do |metadata, payload|
    output = "#{output} \n Received a message: #{payload}. Disconnecting..."

    connection.close {
      EventMachine.stop { exit }
    }
   end
   x.publish "#{SecureRandom.uuid.to_s}", :routing_key => q.name   
  end
 "<h3>#{output}</h1>"
  rescue => e
    "#{e.message} #{e.backtrace}"
    raise e
  end

end

