<?php
$_ENV{'ANTELOPE'} = "/opt/antelope/5.0-64";
#
if( !extension_loaded( "Datascope" ) ) { 
        dl( "Datascope.so" ) or die( "Failed to dynamically load Datascope.so" ) ; 
}
$cwd = getcwd();

clearstatcache();

# global variables	
$pfdir = '../pf';
$parameterspf = $pfdir . '/parameters.pf';
$WEBPLOTSPATH = "/usr/local/mosaic/AVO/internal/avoseis/bronco/TreMoR/plots";
#$WEBPLOTSPATH = "/usr/local/mosaic/AVO/internal/avoseis/coho/TreMoR/plots";
#$WEBPLOTS = "http://giseis.alaska.edu/AVO/internal/avoseis/bronco/TreMoR/plots";
#$WEBPLOTS = "http://giseis.alaska.edu/AVO/internal/avoseis/coho/TreMoR/plots";
$WEBPLOTS = "../plots";
#$WEBPLOTS = "../../../coho/TreMoR/plots";
$subnets = pfget($parameterspf, 'subnetnames');

?>
