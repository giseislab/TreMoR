<?php
include('./includes/antelope.inc');

$page_title = 'IceWeb Spectrogram Mosaic';
$css = array( "style.css" );
$googlemaps = 0;
$js = array();

// Standard XHTML header
include('./includes/header.inc');

?>

<body bgcolor="#FFFFFF">

<?php

	# global variables	
	$debugging = 0;
	$showmenu = 1;
	if (!isset($_REQUEST['subnet'])) {
		$showmenu = 1;
	}
	

	# header files
	include('./includes/daysPerMonth.inc');
	include('./includes/mosaicMaker.inc');

	# There should be 4 possibilities
	# 1. sgram is set as a CGI parameter, which means arrows have been clicked on. In this case, other parameters should be ignored.
	# 2. only a subnet (from menu) - which should link to latest sgram
	# 3. subnet & date/time parameters - can work out the sgram
	# 4. no CGI parameters - which should display menu only

	# Test the sgram CGI parameter & set sgram
	$sgram = !isset($_REQUEST['sgram'])? NULL : $_REQUEST['sgram'];	
	if (isset($sgram)) {
		### OPTION 1: sgram CGI parameter is set                                     ###
		### This is a request from clicking a left or right arrow on this page       ###
		### We want to set the date/time parameters for the form from basename sgram ### 
		$datetime = basename($sgram);
		$year = substr($datetime, 0, 4);
		$month = substr($datetime, 4, 2);
		$day = substr($datetime, 6, 2);
		$hour = substr($datetime, 9, 2);
		$minute = substr($datetime, 11,2);
		$pathParts = explode("/", $sgram);
		$subnet = $pathParts[1];
	}
	else
	{

		# Set date/time variables from CGI parameters if available, otherwise from current date/time
	 	# set current date/time if there is not one already
		$timenow = now(); 
		list ($year, $month, $day, $hour, $minute) = epoch2YmdHM($timenow);
		$minute = floorminute($minute);

		$year = !isset($_REQUEST['year'])? $year : $_REQUEST['year'];
		$month = !isset($_REQUEST['month'])? $month : $_REQUEST['month'];
		$day = !isset($_REQUEST['day'])? $day : $_REQUEST['day'];
		$hour = !isset($_REQUEST['hour'])? $hour : $_REQUEST['hour'];
		$minute = !isset($_REQUEST['minute'])? $minute : $_REQUEST['minute']; 

		# For entry from the form, make sure it has correct number of digits
		$year = mkNdigits($year, 4);
		$month = mkNdigits($month, 2);
		$day = mkNdigits($day, 2);
		$hour = mkNdigits($hour, 2);
		$minute = mkNdigits($minute, 2); 

		# Lets also set subnet
		$subnet = !isset($_REQUEST['subnet'])? NULL : $_REQUEST['subnet'];	

		if (isset($subnet)) {
			if (isset($_REQUEST['year'])) {
				### OPTION 3: subnet and date/time CGI parameters set ###
				### This is a request from the form on this page      ###
				### We can form sgram from those variables            ###
				$sgram =  "../plots/sp/$subnet/$year/$month/$day/".$year.$month.$day."T".$hour.$minute."00.png";	
			}
			else
			{
				### OPTION 2: subnet CGI parameter set, but not date/time                ###
				### The request has come from a link on the AVO internal page menu       ###
				### In this case, we want to select the latest spectrogram available     ###
				$sgram = NULL;

			}
		}
		else
		{
			### OPTION 4: no CGI parameters                                ###
			### Someone has just typed this webpage's URL in a web browser ###
			### In this case, we don't display any spectrogram             ###
			### We could default to the current date/time though           ###
			$subnet = NULL;
			$sgram = NULL;
		}
	}


		
	# Degugging
	if ($debugging == 1) {
		echo "<p>subnet = $subnet</p>\n";
		echo "<p>year = $year</p>\n";
		echo "<p>month = $month</p>\n";
		echo "<p>day = $day</p>\n";
		echo "<p>hour = $hour</p>\n";
		echo "<p>minute = $minute</p>\n";
		echo "<p>sgram = $sgram</p>\n";
		echo "<hr/>\n";
	}

	# Start form
	echo "<form method=\"get\"> ";


	# Call up the appropriate spectrogram
	if(isset($subnet))
	{

		# set previous subnet & next subnet
		$i = array_search($subnet, $subnets);
		if ($i > 0) {
			$previousSubnet = $subnets[$i - 1];
		}		
		else	
		{ 
			$previousSubnet = NULL;
		}
			
		if ($i < count($subnets) - 1) {
			$nextSubnet = $subnets[$i + 1];
		}
		else
		{
			$nextSubnet = NULL;
		}


		if (isset($year) && isset($month) && isset($day) && isset($hour)  && isset($minute)  ) 
		{
			# make sure the date is valid
			if(!checkdate($month,$day,$year)){
				echo "<p>invalid date</p>";
	 		}
			else
			{

				# Search for files
				$pattern = "../plots/sp/$subnet/$year/$month/$day/$year*.png";
				$files = glob($pattern);
				sort($files);
				$numfiles = count($files);
				
	
				# Is sgram set?
				if (!isset($sgram)) { # from the side menu
					$sgram = end($files);
				}
			
				# The current time
				list ($cyear, $cmonth, $cday, $chour, $c1minute) = epoch2YmdHM(now());
				$cminute = floorminute($c1minute);


				# Time parameters of previous spectrogram and its path
				list ($pyear, $pmonth, $pday, $phour, $pminute, $psecs) = addSeconds($year, $month, $day, $hour, $minute, 0, -600);
				$pminute=floorminute($pminute);
				$previous_sgram = "../plots/sp/$subnet/$pyear/$pmonth/$pday/".$pyear.$pmonth.$pday."T".$phour.$pminute."00.png";

				# Time parameters of next spectrogram & its path
				list ($nyear, $nmonth, $nday, $nhour, $nminute, $nsecs) = addSeconds($year, $month, $day, $hour, $minute, 0, 600);
				$nminute=floorminute($nminute);
				$next_sgram = "../plots/sp/$subnet/$nyear/$nmonth/$nday/".$nyear.$nmonth.$nday."T".$nhour.$nminute."00.png";

				# Age of previous spectrogram
				$pAge = timeDiff($pyear, $pmonth, $pday, $phour, $pminute, $psecs, $cyear, $cmonth, $cday, $chour, $cminute, 0);

				# Age of current spectrogram
				$age = $pAge - 600;

				# Age of next spectrogram
				$nAge = $age - 600;


				# Add sound file links & imageMap? 
				#if ($soundOn) {
	
					// Create image map from soundfiles
					$pattern = "../sound/$subnet/$year/$month/$day/".$year.$month.$day."T".$hour.$minute."00_*.*";
					chdir($WEB_PLOTS);
					$soundfiles = glob("$pattern");
					$numsoundfiles = count($soundfiles);
				#	echo "<p>Got $numsoundfiles files matching $pattern</p>";
					if ($numsoundfiles > 0) {
						$imageSizeX = 487;
						$imageSizeY = 648;
						$imageTop = 45;
						$imageBottom = 97;
						$stationNum = 0;
						$panelSizeY = ($imageSizeY - $imageTop - $imageBottom) / $numsoundfiles;
						$xUpperLeft = 0;
						$xLowerRight = $imageSizeX;
						echo "<map name=\"mymap\">\n";
						foreach ($soundfiles as $soundfile) {
							$yUpperLeft = ($imageTop + $panelSizeY * $stationNum);
							$yLowerRight = ($yUpperLeft + $panelSizeY);
							echo "<area shape=\"rect\" href=\"$soundfile\" coords=\"$xUpperLeft,$yUpperLeft  $xLowerRight,$yLowerRight\">\n";
							$stationNum++;
						}
						echo "</map>\n";
					}
				#}	
				
		
				####### Output a table including arrows and current spectrogram   
				echo "<table>\n";

				# PREVIOUS SUBNET
				echo "<tr>\n";
				echo "\t<td>&nbsp;</td>\n";
				echo "\t<td><a href=\"events10min.php?subnet=$previousSubnet&year=$year&month=$month&day=$day&hour=$hour&minute=$minute\">$previousSubnet</a></td>\n";
				echo "\t<td>&nbsp;</td>\n";
				echo "</tr>\n";

				echo "<tr>\n";

				# PREVIOUS SGRAM
				# This style of link passes the sgram CGI parameter: this is why we don't use <a href=><img src=></a>
				if ($pAge >= 0) {
					echo "\t<td><input type=\"image\" src=\"images/left_arrow.gif\" name=\"sgram\" value=\"$previous_sgram\"></td>\n";
				}

				# CURRENT SGRAM
				if ($age >= 0) {

					if (file_exists($sgram)) {
						echo "\t<td>";
						echo "<img usemap=\"#mymap\" src=\"$sgram\" />";
						$evdet = "../live/10minevents/$subnet/$year/$month/$day/".$year.$month.$day."T".$hour.$minute."00.png"; # ????
						if (file_exists($evdet)) {
							echo "<br/><img src=\"$evdet\" />";
						}
						else
						{
							echo "<br/>The <a href=\"$evdet\" />image</a> you asked for does not exist\n";;
						}
						echo "<br/><img src=\"sp/colorbar.png\" />";
						echo "</td>\n";
					}
					else
					{
						#echo "\t<td><img usemap=\"#mymap\" src=\"../plots/sp/noLargeImage.png\"></td>\n";
						echo "<td><h3>Sorry, the spectrogram image you requested does not exist.<br/>($sgram)<br/>Click <a href=\"sgram10min.php?subnet=$subnet\"> here </a> for most recent image</h3></td>";

					}
				}
				else
				{
					echo "<td><h3>The spectrogram date/time you requested is in the future.<br/>Click <a href=\"sgram10min.php?subnet=$subnet\"> here </a> for most recent image</h3></td>";
				}

				# NEXT SGRAM
				# This style of link passes the sgram CGI parameter: this is why we don't use <a href=><img src=></a>
				if ($nAge >= 0) {
					echo "\t<td><input type=\"image\" src=\"images/right_arrow.gif\" name=\"sgram\" value=\"$next_sgram\"></td>\n";
				}

				echo "</tr>\n";

				# NEXT SUBNET
				echo "<tr>\n";
					echo "\t<td>&nbsp;</td>\n";
					echo "\t<td><a href=\"events10min.php?subnet=$nextSubnet&year=$year&month=$month&day=$day&hour=$hour&minute=$minute\">$nextSubnet</a></td>\n";
					echo "\t<td>&nbsp;</td>\n";
				echo "</tr>\n";


				echo "</table>\n";
				### END TABLE

				if ($numsoundfiles > 0) {
					echo "<p>Click on the spectrogram panels above to listen to the seismic data</p>\n"; 
				}
		
			}
		}
	}
	
	else
	{

		echo "<h1>Welcome to the IceWeb Spectrogram Mosaic Maker!</h1>";

	}

 
	# Show Menu?
	if ($showmenu) {

		echo "<hr/>\n";

		# Start table
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
	
		################## START TIME
		echo "<tr><td>Time (UTC):</td><td>\n";
		# start new table inside this cell
		echo "<table><tr>\n";
	
		# Year widgit
		echo "<td>Year:</td>\n";
		echo "<td><input type=\"text\" name=\"year\" value=\"$year\" size=\"4\"> ";
		echo "</td>\n";
	
		# Month widgit
		echo "<td>Month:</td>\n";
		echo "<td><input type=\"text\" name=\"month\" value=\"$month\" size=\"2\"> ";
		echo "</td>\n";
	
		# Day widgit
		echo "<td>Day:</td>\n";
		echo "<td><input type=\"text\" name=\"day\" value=\"$day\" size=\"2\"> ";
		echo "</td>\n";
	
		# Hour widgit
		echo "<td>Hour:</td>\n";
		echo "<td><input type=\"text\" name=\"hour\" value=\"$hour\" size=\"2\"> ";
		echo "</td>\n";
	
		# Minute widgit
		echo "<td>Minute:</td>\n";
		echo "<td><select name=\"minute\"> ";
		echo "<option value=\"$minute\" SELECTED>$minute</option>";
		$minutes = array("00", "10", "20", "30", "40", "50");
		foreach ($minutes as $minute_option) {
			print "<option value=\"$minute_option\">$minute_option</option> ";
		}
		print "</select>";
		echo "</td>\n";
	
		# end this table
		echo "</tr></table>\n";
	
		# end this cell and row
		echo "</td></tr>\n";
		###################### END OF START TIME
	
		# Submit & Reset buttons
		echo "<tr>\n";
		print "<td><input type=\"submit\" name=\"submit\" value=\"Get Spectrogram\"></td>\n";
		$sgramtime = str2epoch("$year/$month/$day $hour:$minute:00");
		list ($syear, $smonth, $sday, $shour, $sminute) = epoch2YmdHM($sgramtime - 3600);
		print "<td><a href=\"mosaicMakerDateTime.php?subnet=$subnet&year=$syear&month=$smonth&day=$sday&hour=$shour&minute=$sminute&numhours=2\">Make Mosaic</a></td>\n";
		echo "</tr>\n";
	
		# End the table
		echo "</table>\n";
	
		# Horizontal rule
		print "<hr />";

	}
	else
	{
		# Hide the variables
		echo "<input type='hidden' name='subnet' value=\"$subnet\">\n";
		echo "<input type='hidden' name='year' value=\"$year\">\n";
		echo "<input type='hidden' name='month' value=\"$month\">\n";
		echo "<input type='hidden' name='day' value=\"$day\">\n";
		echo "<input type='hidden' name='hour' value=\"$hour\">\n";
		echo "<input type='hidden' name='minute' value=\"$minute\">\n";
	}



	# End form
	echo "</form>\n";

	# Server time
	echo "<hr/>";
	echo "<p>Server processed your request at: $cyear/$cmonth/$cday $chour:$c1minute</p>";		

?>


</body>
</html>

