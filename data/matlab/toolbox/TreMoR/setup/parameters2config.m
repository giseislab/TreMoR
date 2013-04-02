function parameters2config(KM, MAXCHANS, MAXUSED)
disp('This program needs to be rewritten so that it uses the volcanoes places db I use for Python scripts, and not the individual volcano.pf files which I moved to pf/obsolete')
if ~exist('KM', 'var')
	KM = 50.0; % KM
end
if ~exist('MAXCHANS', 'var')
	MAXCHANS = 50; 
end
if ~exist('MAXUSED', 'var')
	MAXUSED = 6; 
end
[paths,PARAMS]=pf2PARAMS();

disp('The subnets chosen are:');
for c=1:length(PARAMS.subnetnames)
	disp(sprintf('%d: %s',c, PARAMS.subnetnames{c}));
end
outfile = 'params/subnets.d';
laststation = 'ZZZZ';
if exist(outfile, 'file')
    system(sprintf('mv %s %s.%s',outfile,outfile,datestr(now,30)));
end
fout = fopen(outfile, 'w');
for c=1:length(PARAMS.subnetnames)
    subnets.name = PARAMS.subnetnames{c};
    subnets.source = pf2source(subnets.name);
    subnets.stations = getStationsWithinDist(subnets.source.longitude, subnets.source.latitude, KM, paths.DBMASTER, MAXCHANS);
    for k=1:length(subnets.stations)
	try
        	subnets.stations(k).response = response_get_from_db(subnets.stations(k).name, subnets.stations(k).channel, now, PARAMS.f, paths.DBMASTER);
	catch
        	subnets.stations(k).response = [];
	end
    end
    usesubnet = ~excluded_subnet(subnets.name);
    fprintf(fout, 'SUBNET\t%s\t%.4f\t%.4f\t%d\n',subnets.name, subnets.source.latitude, subnets.source.longitude,usesubnet);
    totalinuse = 0;
    for k=1:length(subnets.stations)
        useit=0;
        if regexp(subnets.stations(k).channel, '[BES]HZ')  & (totalinuse < MAXUSED) & (~excluded_scnl(subnets.stations(k).name, subnets.stations(k).channel) & ~strcmp(subnets.stations(k).name, laststation))
                useit = 1;
		totalinuse = totalinuse + 1;
		laststation = subnets.stations(k).name;
        end
        fprintf(fout, 'scn\t%s.%s.%s\t%.4f\t%.4f\t%.2f\t%.4f\t%d\n',subnets.stations(k).name, subnets.stations(k).channel, get(subnets.stations(k).scnl, 'network'), subnets.stations(k).site.lat, subnets.stations(k).site.lon, subnets.stations(k).site.elev, subnets.stations(k).response.calib, useit);
    end
    fprintf(fout, '\n\n'); % end of subnet

end   

function exclude = excluded_scnl(sta, chan)
exclude = false;
str = sprintf('%s.%s',sta,chan);
fid = fopen('params/exclude_scnl.d');
tline = fgetl(fid);
while ischar(tline)
    	%disp(tline)
    	tline = fgetl(fid);
	if length(tline)==0
		continue;
	else
		if strcmp(tline(1), '#')
			continue;
		end
		if ischar(tline)
			if (regexp(tline,str))
				exclude = true;
			end
		end
	end	
end
fclose(fid);

function exclude = excluded_subnet(subnet)
exclude = false;
fid = fopen('params/exclude_subnet.d');
tline = fgetl(fid);
while ischar(tline)
    	%disp(tline)
    	tline = fgetl(fid);
	if strcmp(tline(1), '#')
		next;
	end
	if ischar(tline)
		if (strcmp(tline,subnet))
			exclude = true;
		end
	end	
end
fclose(fid);






function source = pf2source(subnet);
%PF2SOURCE return a structure containing the longitude and latitude of what is considered the be the 
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

source.longitude = -999;
source.latitude = -999;

% open pointer to subnet parameter file
try
[pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);
if existsSubnetPF
    debug.print_debug(['searching for volcano source coordinates in ',subnet,'.pf'],3);
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
	%[source.longitude, source.latitude, minlon, maxlon, minlat, maxlat] = readavovolcs(subnet, '/avort/modrun/pf/avo_volcs.pf');
    [source.longitude, source.latitude, minlon, maxlon, minlat, maxlat] = catalog.readavovolcs(subnet);
end

if (source.longitude == -999 || source.latitude == -999)
	disp(['No source coordinates found for ',subnet]);
end

debug.print_debug(sprintf('< %s', mfilename),4)




function [pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);
%OPENPOINTERTOSUBNET return a pointer to the parameter file for subnet.
%
% [pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);
% 	existsSubnetPF is either TRUE or FALSE depending on whether the subnet file was found (& opened) or not.
%
% The paths.PFS variable must be set to the directory where the subnet.pf resides
%
% Glenn Thompson, 1998 - 2008

global paths

debug.print_debug(sprintf('> %s', mfilename),5)

% create pointer to iceweb parameter file
parameterFilename = catpath(paths.PFS,sprintf('subnet_%s',subnet));
if exist([parameterFilename,'.pf'])
	pointerToSubnetPF = dbpf(parameterFilename);
	existsSubnetPF = 1; 
else
	disp([parameterFilename,' does not exist'])
	pointerToSubnetPF = -1;
	existsSubnetPF = 0;
end

debug.print_debug(sprintf('< %s', mfilename),5)






