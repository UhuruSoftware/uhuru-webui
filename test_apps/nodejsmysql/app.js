require("cf-autoconfig");
var express = require("express");
var app = express();

app.get('/', function(req, res) {
    var mysql      = require('mysql');
    var connection = mysql.createConnection();

    connection.connect();
  
    connection.query('SELECT NOW() as time_now;', function(err, rows, fields) {
    if (err) throw err;

    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.write(rows[0].time_now);
    res.end('\n');

    console.log('The solution is: ');
    });
    connection.end();
    
    res.send('Hello from Cloud Foundry');
});

app.listen(process.env.VCAP_APP_PORT || 3000);
