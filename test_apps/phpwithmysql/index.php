<?php
$decodedDbData = json_decode($_SERVER["VCAP_SERVICES"], true);
$credentials = $decodedDbData['mysql-5.5'][0]["credentials"];

$con = mysql_connect($credentials["hostname"], $credentials["user"], $credentials["password"]);
if (!$con)
{
	header('HTTP/1.1 500 Internal Server Error');
	print mysql_error();
}
else
{
	$succeeded = mysql_select_db($credentials["name"]); 

	if ($succeeded)
		print 'success';
	else
	{
		header('HTTP/1.1 500 Internal Server Error');
		print mysql_error();
	}
		
	mysql_close($con);
}		


?>