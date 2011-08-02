<?php
include('./includes/antelope.inc');

$page_title = 'IceWeb Spectrogram Mosaic';
$css = array( "style2.css" );
$googlemaps = 0;
$js = array();

// Standard XHTML header
include('./includes/header.inc');

?>

<body bgcolor="#FFFFFF">

<?php
	# global variables
	$debugging = 0;

	# header files
	include('./includes/daysPerMonth.inc');
	include('./includes/mosaicMaker.inc');
	#include('./includes/mosaicMakerTable.inc');

	# Set convenience variables from CGI parameters
	$subnet = !isset($_REQUEST['subnet'])? NULL : $_REQUEST['subnet'];
	$starthour = !isset($_REQUEST['starthour'])? NULL : $_REQUEST['starthour'];
	$endhour = !isset($_REQUEST['endhour'])? NULL : $_REQUEST['endhour'];
		
	# Degugging
	if ($debugging == 1) {
		echo "<p>subnet = $subnet</p>\n";
		echo "<p>starthour = $starthour</p>\n";
		echo "<p>endhour = $endhour</p>\n";
		echo "<p>REQUEST[subnet] = ".$_REQUEST['subnet']."</p>\n";
		echo "<hr/>\n";
	}

	# Start page
	#echo "<h1>IceWeb Mosaic Maker</h1>";
	# Show Mosaic 
	if(isset($_REQUEST["subnet"])) {
		if (isset($_REQUEST["starthour"]) && isset($_REQUEST["endhour"])) {
			if ($starthour > $endhour) {
				mosaicMaker($subnet, $starthour, $endhour, $WEBPLOTS);
			}
			else
			{
				echo "<p>Start hours ago must be greater than end hours ago</p>\n";
			}
		} 
	}
	else
	{

		echo "<h1>Welcome to the IceWeb Spectrogram Mosaic Maker!</h1><p>This page is a link to pre-generated jpeg files generated by the Matlab program iceweb.m which runs every 10 minutes, generating static content to aid rapid response</p>";
#		$subnet = ""; $starthour = 2; $endhour = 0;
#		$_REQUEST["subnet"]=""; $_REQUEST["starthour"]=""; $_REQUEST["endhour"]=""; 


	}

	# Horizontal rule
	print "<hr />";


	# Start form
	echo "<form method=\"get\"> ";

	# Start table for form elements
	echo "<table>\n\n";

	# Subnet widgit
	echo "<tr><td>Subnet</td>\n";
	echo "<td><select name=\"subnet\"> ";
	echo "<option value=\"$subnet\" SELECTED>$subnet</option>";
	foreach ($subnets as $subnet_option) {
		print "<option value=\"$subnet_option\">$subnet_option</option> ";
	}
	print "</select>";
	echo "</td></tr>\n";

	# Start hour widgit
	echo "<tr><td>Start</td>\n";
	echo "<td><input type=\"text\" name=\"starthour\" value=\"$starthour\" size=\"4\"> ";
	echo " hours ago </td></tr>\n";

	# End hour widgit
	echo "<tr><td>End</td>\n";
	echo "<td><input type=\"text\" name=\"endhour\" value=\"$endhour\" size=\"4\"> ";
	echo " hours ago</td></tr>\n";

	# Submit & Reset buttons
	echo "<tr>\n";
	print "<td><input type=\"submit\" name=\"submit\" value=\"Make Mosaic\"></td>\n";
	$timestart = now() - $starthour * 3600;
	list($syear, $smonth, $sday, $shour, $sminute) = epoch2YmdHM($timestart);

	$sminute=floorminute($sminute); 
	$numhours = $starthour - $endhour;
	print "<td><a href=\"mosaicMakerDateTime.php?subnet=$subnet&year=$syear&month=$smonth&day=$sday&hour=$shour&minute=$sminute&numhours=$numhours\">Select by date/time</a></td>\n";

	echo "</tr>\n";

	# End the table
	echo "</table>\n";

	# Horizontal rule
	print "<hr />";

	# End form
	echo "</form>\n";

?>


<div><script language="Javascript" type="text/javascript">now = new Date;document.write("<p>Generated: " + now.toUTCString()  + "</p>");</script></div>

</body>
</html>



