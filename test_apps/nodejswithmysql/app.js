require("cf-autoconfig");
var express = require("express");
var app = express();

var check_connection = function(req, res){

    var mysql      = require('mysql');
    var connection = mysql.createConnection();

    connection.connect();

    connection.query('SELECT NOW() as time_now;', function(err, rows, fields) {
        if (err)
        {
            res.writeHead(500, {"Content-Type": "text/plain"});
            res.write(String(err));
            res.end();
        }
        else
        {
            res.writeHead(200, {"Content-Type": "text/plain"});
            res.write(String(rows[0].time_now));
            res.write("OK");
            res.end();
        }

        console.log('The solution is: ' );
    });

    connection.end();
}

app.get('/', function(req, res) {
    check_connection(req, res);
});

app.listen(process.env.VCAP_APP_PORT || 3000);
