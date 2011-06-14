<?php
include('./includes/antelope.inc');

// Read in CGI parameters
$days = !isset($_REQUEST['days'])? 3 : $_REQUEST['days'];	
$subnet = !isset($_REQUEST['subnet'])? 'Redoubt' : $_REQUEST['subnet'];	

$page_title = "$subnet IceWeb Reduced Displacement";
$css = array( "style.css" );
$googlemaps = 0;
$js = array();

// Standard XHTML header
include('./includes/header.inc');
include('./includes/mosaicMaker.inc');


?>

<body bgcolor="#FFFFFF">

<?php

$plot = isset($_REQUEST['plot']) ? $_REQUEST['plot'] : 'LogPlot';
$map = isset($_REQUEST['map']) ? $_REQUEST['map'] : 'HideMap';

# Plot log
$imgfilebase = sprintf("$WEBPLOTS/drs/".$subnet."_%.1f",$days);
if ($plot=="LinearPlot") {
	$imgfilebase .= "lin";

}
echo "<img src=\"$imgfilebase.png\" >\n";


echo "<p><a href=\"http://www.avo.alaska.edu/wiki/index.php/IceWeb\">IceWeb</a> Surface Wave Reduced Displacement (D<sub>rs</sub>) Plot - Last $days days</br>\n";

echo "<br/>D<sub>rs</sub> is computed for each 60 second time window\n";

#if ($days > .5) {
#	$factor = round(0.49 + $days * 2); # changed
#	echo "<br/>These data are downsampled by a factor of $factor here to better fit the display<br/>\n";
#}
echo "<hr/>";
# Map on 
if ($map=="ShowMap") {
	echo "<img src=\"$WEBPLOTS/maps/".$subnet."_map.png\">\n";

	echo "<br/><p>Blue triangles mark stations, numbers show distance in km from the source marked with a red star</p>";
}
echo "<form method=\"get\" >";
print "<td><input type=\"hidden\" name=\"plot\" value=\"$plot\"></td>\n";
print "<td><input type=\"hidden\" name=\"map\" value=\"$map\"></td>\n";
print "<td><input type=\"hidden\" name=\"subnet\" value=\"$subnet\"></td>\n";
print "<td><input type=\"hidden\" name=\"days\" value=\"$days\"></td>\n";


# ADDING A DUMMY IF TO SKIP FOLLOWING CODE, GT 2009/10/02
if (0) {
echo "<table><tr>\n";

# Plot linear/log button
if ($plot=="LinearPlot") {
	print "<td><input type=\"submit\" name=\"plot\" value=\"LogPlot\"></td>\n";
}
else
{
	print "<td><input type=\"submit\" name=\"plot\" value=\"LinearPlot\"></td>\n";
}
} # END OF DUMMY IF / SKIPPED CODE

# Map on/off button
if ($map=="ShowMap") {
	print "<td><input type=\"submit\" name=\"map\" value=\"HideMap\"></td>\n";
}
else
{
	print "<td><input type=\"submit\" name=\"map\" value=\"ShowMap\"></td>\n";
}
echo "</tr></table>\n";


echo "</form>";


# The current time
list ($cyear, $cmonth, $cday, $chour, $c1minute) = epoch2YmdHM(now());

# Server time
echo "<hr/>";
echo "<p>Server processed your request at: $cyear/$cmonth/$cday $chour:$c1minute UTC</p>";	
$stat = stat("$imgfilebase.png");
$mtime = epoch2str($stat['mtime'],"%Y/%m/%d %H:%M");
echo "<p>Plot updated at $mtime UTC</p>";

?>

</body>
</html>
