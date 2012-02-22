function source = pf2source(subnet);
%pf2source returns a structure containing the longitude and latitude of what is considered the be the 
% seismic source for a particular subnet. This is needed in order to compute reduced displacement. 
% SOURCE = pf2source(SUBNET) 
%
% It is best to illustrate this by example:
% SOURCE = pf2source('Pavlof')
% 	In this case the subnet is 'Pavlof'. First the program will check for the longitude and latitude in
%	the parameter file 'Pavlof.pf'. If nothing is found there, it will check the avovolcs.pf file.
%   Note that a subnet pf file like 'Pavlof.pf' is not necessarily IceWeb specific.
%
% Glenn Thompson, 2007-9.

global paths 
print_debug(sprintf('> %s', mfilename),4)

source.longitude = -999;
source.latitude = -999;

% open pointer to subnet parameter file
try
[pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);
if existsSubnetPF
    print_debug(['searching for volcano source coordinates in ',subnet,'.pf'],3);
    try 
	pointerToSource =  pfget_arr(pointerToSubnetPF,'source');
    	source.longitude = pfget(pointerToSource,'longitude');
        source.latitude  = pfget(pointerToSource,'latitude');
    end
else
    disp(['could not find parameter file for ',subnet]);
end
end

if (source.longitude == -999)
	[source.longitude, source.latitude, minlon, maxlon, minlat, maxlat] = readavovolcs(subnet, '/avort/modrun/pf/avo_volcs.pf');
end

if (source.longitude == -999 || source.latitude == -999)
	disp(['No source coordinates found for ',subnet]);
end

print_debug(sprintf('< %s', mfilename),4)
