<?php
$decodedDbData = json_decode($_SERVER["VCAP_SERVICES"], true);
$credentials = $decodedDbData['mssql-2008'][0]["credentials"];

$con = mssql_connect($credentials["hostname"], $credentials["user"], $credentials["password"]);
if (!$con)
{
	header('HTTP/1.1 500 Internal Server Error');
	print mssql_error();
}
else
{
	$succeeded = mssql_select_db($credentials["name"]); 

	if ($succeeded)
		print 'success';
	else
	{
		header('HTTP/1.1 500 Internal Server Error');
		print mssql_error();
	}
		
	mysql_close($con);
}		


?>