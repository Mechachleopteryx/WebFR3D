<?php
$dbhost = "localhost";
$dbuser = "webfr3d";
$dbpass = "HKc4aLx6K7nVtG2U";
$dbname = "PDB";
//Connect to MySQL Server
$link = mysql_connect($dbhost, $dbuser, $dbpass);
//Select Database
mysql_select_db($dbname) or die(mysql_error());
// Retrieve data from Query String
$pdb = mysql_real_escape_string($_POST['pdb']);

$query = "SELECT * FROM `Files` WHERE Name = '$pdb'";
$result = mysql_query($query) or die(mysql_error());

$row = mysql_fetch_array($result);

$return = "<u>Title</u>: $row[Title]<br>";
$return .= "<u>Resolution</u>: $row[Resolution]<br>";
$return .= "<u>Method</u>: $row[Method]<br>";
$return .= "<u>Organism</u>: $row[Source]<br><br>";
$return .= "<a href = 'http://www.pdb.org/pdb/explore/explore.do?structureId=$pdb' target='_blank'>More</a><br>";
echo $return;
mysql_close($link);

?>