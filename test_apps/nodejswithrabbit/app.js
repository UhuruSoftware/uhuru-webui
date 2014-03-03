require("cf-autoconfig");
var express = require("express");
var app = express();

var check_connection = function(req, res){

    var amqp      = require('amqp');
    var connection = amqp.createConnection();

    connection.on('ready', function (err) {
        var message = 'Hello Cloud!';
        var exchange = connection.exchange(''); // get the default exchange
        var queue = connection.queue('queue1', {}, function() { // create a queue
            queue.subscribe(function(msg) { // subscribe to that queue
                console.log(msg.body); // print new messages to the console
            });

            // publish a message
            exchange.publish(queue.name, {body: message});
        });

        if (err)
        {
            res.writeHead(500, {"Content-Type": "text/plain"});
            res.write(String(err));
            res.end();
        }
        else
        {
            res.writeHead(200, {"Content-Type": "text/plain"});
            res.write(message);
            res.write("OK");
            res.end();
        }
    });
}

app.get('/', function(req, res) {
    check_connection(req, res);
});

app.listen(process.env.VCAP_APP_PORT || 3000);
