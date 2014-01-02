<?php require_once('Connections/localhost.php'); ?>
<?php require_once('Connections/functions.php'); ?>
<?php

$colname_user = "-1";
if (isset($_POST['urn'])) {
  $colname_user = $_POST['urn'];
}
mysql_select_db($database_localhost, $localhost);
$query_user = sprintf("SELECT * FROM users WHERE urn = %s", GetSQLValueString($colname_user, "text"));
$user = mysql_query($query_user, $localhost) or die(mysql_error());
$row_user = mysql_fetch_assoc($user);
$totalRows_user = mysql_num_rows($user);
die("name=".$row_user['firstname']." ".$row_user['lastname']."&posts=".$row_user['posts']);
?>
<?php
mysql_free_result($user);
?>
