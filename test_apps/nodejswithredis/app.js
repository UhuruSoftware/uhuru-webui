require("cf-autoconfig");
var express = require("express");
var app = express();

var check_connection = function(req, res){

    var redis = require('redis');
    var client = redis.createClient();

    client.on("error", function (err) {
        console.log("Error " + err);
        res.writeHead(500, {"Content-Type": "text/plain"});
        res.write(String(err));
        res.end();
    });

    client.set("last_ip", req.connection.remoteAddress, redis.print);
}

app.get('/', function(req, res) {
    check_connection(req, res);
    res.send('Hello from Cloud');
});

app.listen(process.env.VCAP_APP_PORT || 3000);
