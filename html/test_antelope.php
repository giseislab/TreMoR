<?php
$_ENV{'ANTELOPE'} = "/opt/antelope/5.0-64";
#
if( !extension_loaded( "Datascope" ) ) { 
        dl( "Datascope.so" ) or die( "Failed to dynamically load Datascope.so" ) ; 
}
$cwd = getcwd();

$page_title = 'Test Antelope';
$css = array( "style.css" );
$googlemaps = 0;
$js = array();

// Standard XHTML header
include('./includes/header.inc');

?>

<body bgcolor="#FFFFFF">

<p>If this works you should see a list of subnets from parameters.pf here</p>

<?php

	clearstatcache();

	# global variables	
	$pfdir = '../pf';
	$parameterspf = $pfdir . '/parameters.pf';
	$WEB_PLOTS = "../plots";
	$subnets = pfget($parameterspf, 'subnetnames');


	# header files
	include('./includes/daysPerMonth.inc');
	include('./includes/mosaicMaker.inc');

	foreach ($subnets as $subnet) {
		echo "<p>$subnet</p>\n";
	}

?>


</body>
</html>

