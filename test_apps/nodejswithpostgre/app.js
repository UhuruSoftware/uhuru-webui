require("cf-autoconfig");
var express = require("express");
var app = express();

var check_connection = function(req, res){

    var pg     = require('pg');
    pg.connect(process.env.DATABASE_URL, function(err, client) {
        var query = client.query('SELECT NOW() as time_now;');

        query.on('row', function(row) {
            if (err)
            {
                res.writeHead(500, {"Content-Type": "text/plain"});
                res.write(String(err));
                res.end();
            }
            else
            {
                console.log(JSON.stringify(row));
                res.writeHead(200, {"Content-Type": "text/plain"});
                res.write(JSON.stringify(row));
                res.write("OK");
                res.end();
            }
        });
    });
}

app.get('/', function(req, res) {
    check_connection(req, res);
});

app.listen(process.env.VCAP_APP_PORT || 3000);
