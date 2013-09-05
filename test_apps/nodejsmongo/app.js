var env = JSON.parse(process.env.VCAP_SERVICES);
var mongo = env['mongodb-2.0'][0]['credentials'];

var generate_mongo_url = function(obj){
  obj.hostname = (obj.hostname || 'localhost');
  obj.port = (obj.port || 27017);
  obj.db = (obj.name || 'test');

  if(obj.username && obj.password){
    return "mongodb://" + obj.username + ":" + obj.password + "@" + obj.hostname + ":" + obj.port + "/" + obj.db;
  }
  else{
    return "mongodb://" + obj.hostname + ":" + obj.port + "/" + obj.db;
  }
}

var mongourl = generate_mongo_url(mongo);

var record_visit = function(req, res){
  /* Connect to the DB and auth */
  require('mongodb').connect(mongourl, function(err, conn){
    conn.collection('ips', function(err, coll){
      /* Simple object to insert: ip address and date */
      object_to_insert = { 'ip': req.connection.remoteAddress, 'ts': new Date() };

      /* Insert the object then print in response */
      /* Note the _id has been created */
      coll.insert( object_to_insert, {safe:true}, function(err){
        console.log(object_to_insert);
		
		console.log(err);
		
		if (err)
		{
			res.writeHead(500, {'Content-Type': 'text/plain'});
			res.write(err);
			res.end('\n');
		}
		else
		{
			print_visits(req, res);
		}
		
		
      });
    });
  });
}

var print_visits = function(req, res){
/* Connect to the DB and auth */
require('mongodb').connect(mongourl, function(err, conn){
    conn.collection('ips', function(err, coll){
        coll.find({}, {limit:10, sort:[['_id','desc']]}, function(err, cursor){
            cursor.toArray(function(err, items){
                res.writeHead(200, {'Content-Type': 'text/plain'});
                for(i=0; i<items.length;i++){
                    res.write(JSON.stringify(items[i]) + "\n");
                }
                res.end();
            });
        });
    });
});
}


var port = (process.env.VMC_APP_PORT || 3000);
var host = (process.env.VCAP_APP_HOST || 'localhost');
var http = require('http');

http.createServer(function (req, res) {
        record_visit(req, res);
		
    }).listen(port, host);