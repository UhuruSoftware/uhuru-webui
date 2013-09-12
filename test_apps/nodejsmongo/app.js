require("cf-autoconfig");
var express = require("express");
var app = express();

var record_visit = function(req, res){
  require('mongodb').connect('', function(err, conn){
    conn.collection('ips', function(err, coll){
      object_to_insert = { 'ip': req.connection.remoteAddress, 'ts': new Date() };
      coll.insert( object_to_insert, {safe:true}, function(err){
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.write(JSON.stringify(object_to_insert));
        res.end('\n');
      });
    });
  });
}

app.get('/', function(req, res) {
  record_visit(req, res);
});

app.listen(process.env.VCAP_APP_PORT || 3000);