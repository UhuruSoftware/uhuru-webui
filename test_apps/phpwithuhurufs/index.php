<?php
$decodedDbData = json_decode($_SERVER["VCAP_SERVICES"], true);
$credentials = $decodedDbData['uhurufs-0.9'][0]["credentials"];

$conn_id = ftp_connect($credentials["hostname"], intval($credentials["port"]));

if (!$conn_id) 
{
	header('HTTP/1.1 500 Internal Server Error');
	print mysql_error();
}
else
{
	$file = 'somefile.txt';
	$remote_file = 'remotefile.txt';
	
	// login with username and password
	$login_result = ftp_login($conn_id, $credentials["username"], $credentials["password"]);

	// upload a file
	if (ftp_put($conn_id, $remote_file, $file, FTP_ASCII)) {
		//print "success";
	} else {
		header('HTTP/1.1 500 Internal Server Error');
		print mysql_error();
	}

	//check if it's there
	$handle = fopen("ftp://".$credentials["username"].":".
					$credentials["password"]."@".$credentials["hostname"]
					.":".$credentials["port"]."/".$remote_file, "r");
					
	if ($handle)
		print "success";
	else
	{
		header('HTTP/1.1 500 Internal Server Error');
		print mysql_error();
	}	
	
	// close the connection
	ftp_close($conn_id);
}



?>