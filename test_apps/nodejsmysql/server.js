var http = require("http");

function start() {
  function onRequest(request, response) {
    envCopy = {};
    for (e in process.env)
	{
    		console.log(String(e) + " -- " + process.env[e]);
	}
	
	var env = JSON.parse(process.env.VCAP_SERVICES);
	var credentials = env["mysql-5.1"][0]["credentials"];
    
	var mysql      = require('mysql');
	var connection = mysql.createConnection({
	  host     : credentials["hostname"],
	  port: credentials["port"],
	  user: credentials["user"],
	  password: credentials["password"] 
	});
	
	connection.connect();

	connection.query('use ' + credentials["name"], function(err, rows, fields) {
	  if (err)
	  {	  
			response.writeHead(500, {"Content-Type": "text/plain"});
			response.write(String(err));
			response.end();
	  }
	  else
		{
			response.writeHead(200, {"Content-Type": "text/plain"});
			response.write("OK");
			response.end();
		}
	});

	connection.end();
	
 };

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;