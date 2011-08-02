<?php
function mosaicMaker($subnet, $hours_ago_start, $hours_ago_stop, $WEBPLOTS) {

//echo "<p>Hours ago start = $hours_ago_start</p>";
//echo "<p>Hours ago stop = $hours_ago_stop</p>";

	if ($hours_ago_start < 0) {
		$hours_ago_start = 0;
	}

	if ($hours_ago_stop < 0) {
		$hours_ago_stop = 0;
	}

	$numMins = 10;
	$plotsPerRow = 60 / $numMins;

	$timestart = now() - $hours_ago_start * 60 * 60 ;
	list ($year, $month, $day, $hour, $minute) = epoch2YmdHM($timestart);

	$timestop = now() - $hours_ago_stop * 60 * 60 ;
	list ($year_stop, $month_stop, $day_stop, $hour_stop, $minute_stop) = epoch2YmdHM($timestop);

	$timenow = now();
	list ($year_now, $month_now, $day_now, $hour_now, $minute_now) = epoch2YmdHM($timenow);

	echo "<h1>$subnet IceWeb Spectrogram Mosaic</h1>\n";

	$c = 0;
	$latestAge = "?";

	for ( $time = $timestart + ($numMins * 60); $time < $timestop; $time += $numMins * 60) {

		# Get the end date and time for the current image
		list ($year, $month, $day, $hour, $minute) = epoch2YmdHM($time);
		$floorminute = floorminute($minute);
		$timestamp = sprintf("%04d%02d%02dT%02d%02d",$year ,$month, $day, $hour, $floorminute) . "00";

		# Create labels for end hour/minute
		$hhmm = sprintf("%02d:%02d", $hour, $floorminute);

		# Get the start date and time for the current image
		list ($syear, $smonth, $sday, $shour, $sminute) = epoch2YmdHM($time - $numMins * 60);
		$floorsminute= floorminute($sminute);

		# Create labels for start hour/minute
		$oldhhmm  = sprintf("%02d:%02d", $shour, $floorsminute);
	
		# Set the link to the big image file
		$sgramphplink = "sgram10min.php?year=$year&month=$month&day=$day&hour=$hour&minute=$floorminute&subnet=$subnet";

		# work out age of this latest data in this image
		if (($timenow - $time) < 24*60*60) {
			$now = strtotime("$year_now-$month_now-$day_now $hour_now:$minute_now:00");
			$tim = strtotime("$year-$month-$day $hour:$floorminute:00");
			$ageSecs = $now - $tim;
			$ageHours = floor($ageSecs / 3600);
			$ageMins = floor(($ageSecs - (3600 * $ageHours)) / 60);
			$ageStr = sprintf("%dh%02dm", $ageHours, $ageMins);

			if ($ageSecs < 0) {
				$ageHours = floor((-$ageSecs) / 3600);
				$ageMins = floor(((-$ageSecs) - (3600 * $ageHours)) / 60);
				$ageStr = sprintf("-%dh%02dm", $ageHours, $ageMins);

			}
		}


		# Set the thumbnail image file	
		$small_sgram = "$WEBPLOTS/sp/$subnet/$year/$month/$day/small_$timestamp.png";
		if (!file_exists($small_sgram)) {
		#	$small_sgram = "$WEBPLOTS/sp/noImage.png";
		}
		else
		{ 	
			$latestAge = $ageStr;
		}
		


		# (ROW STARTS HERE)
		if (($c % $plotsPerRow)==0) {
			echo "<hr/>\n";
			#echo "<p align=\"center\" >$oldhhmm UTC</p>\n";
			echo "<table border=1><tr><td class=\"tdimg\">$oldhhmm UTC</td>\n";
		}

		# CELL STARTS HERE 			
		#echo "<a href=$sgramphplink class=\"tdimg\" style=\"background-image:url($small_sgram)\" ></a>\n";
		echo "<td class=\"tdimg\"><a href=$sgramphplink><img src=$small_sgram></a></td>\n";
		#echo "<a href=$sgramphplink class=\"tdimg\" >$oldhhmm $hhmm $sgram</a>\n";

		# CELL ENDS HERE

		if (($c % $plotsPerRow)==($plotsPerRow-1)) {
			# ROW ENDS HERE
			#echo "<p align=\"center\" >$hhmm UTC</p>\n";
			echo "<td class=\"tdimg\">$hhmm UTC</td></tr></table>\n";

		}
		

		$c++;
	}
	echo "<p>Latest image shown here has age $latestAge</p>\n";



}

function epoch2YmdHM($e) {
	$numMins=10;
	$year = epoch2str($e, "%Y", "UTC");
	$month = epoch2str($e, "%m", "UTC");
	$day = epoch2str($e, "%d", "UTC");
	$hour = epoch2str($e, "%H", "UTC");
	$minute = epoch2str($e, "%M", "UTC");

	return array($year, $month, $day, $hour, $minute);
}

function floorMinute($minute) {
	$numMins=10;
	$floorminute = floor($minute / $numMins) * $numMins;
	$floorminute = mkNdigits($floorminute, 2);
	return $floorminute;
} 

function mkNdigits($str, $N) {
	while (strlen($str) < $N) 
	{
		$str = "0".$str;
	}
	return $str;
}
function addSeconds($y,$m,$d,$h,$i,$s,$secsToAdd) {
	$t = strtotime("$y/$m/$d $h:$i:$s");
	$t = $t + $secsToAdd;
	$y = date('Y', $t);
	$m = date('m', $t);
	$d = date('d', $t);
	$h = date('H', $t);
	$i = date('i', $t);
	$s = date('s', $t);
	return array($y, $m, $d, $h, $i, $s);
}
function timeDiff($y1, $m1, $d1, $h1, $i1, $s1, $y2, $m2, $d2, $h2, $i2, $s2) {
	$t1 = strtotime("$y1/$m1/$d1 $h1:$i1:$s1");
	$t2 = strtotime("$y2/$m2/$d2 $h2:$i2:$s2");
	return ($t2 - $t1);


}
?>
	
