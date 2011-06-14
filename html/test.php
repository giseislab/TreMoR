<?php
$cwd = getcwd();

$page_title = 'Test';
$css = array( "style.css" );
$googlemaps = 0;
$js = array();

// Standard XHTML header
include('./includes/header.inc');

?>

<body bgcolor="#FFFFFF">

<?php

	clearstatcache();

	# header files
	include('./includes/daysPerMonth.inc');
	include('./includes/mosaicMaker.inc');

?>


</body>
</html>

