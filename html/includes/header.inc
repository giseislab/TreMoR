<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="content-type" content="text/html"; charset=iso-8859-1" />
	<meta http-equiv="refresh" content="60" />

	<title><?php echo $page_title; ?></title>
	<?php
		echo "\n";
		foreach ($css as $cssfile) {
			echo "\t<link rel=\"stylesheet\" href=\"css/$cssfile\" />\n";
		}
		if ($googlemaps == 1) {
			echo "\t<script src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAXvsk9998ISR02l2phHU8XBSfXd_Vn7F8xzcCxmIsDuIu46yPpxTI_Mxhu7CxWYXteCoX3Fn7-edpmA\" type=\"text/javascript\"></script>\n";
		}
		foreach ($js as $jsfile) {
			echo "\t<script src=\"includes/$jsfile\" type=\"text/javascript\"> </script>\n";
		}


	?>
</head>

	

