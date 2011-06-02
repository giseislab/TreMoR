function [subnets, numstations] = subnetsetup(subnet)
%subnetsetup	Setup for IceWeb and other programs
%
% [subnets, numstations] = subnetsetup(subnetname)
% subnets is a structure with a stations element (also a structure) among other things
% for the input subnet 
% Glenn Thompson, September 1999 - March 2008

print_debug(sprintf('> %s', mfilename),2);


%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS

timewindow.start = now;
subnets.name = subnet;

% which subnet?
% note subnet (input) === subnets.name
print_debug(sprintf('Setting up %s',subnet),2);

% get source location for subnet from $subnet.pf
source = pf2source(subnet);
subnets.source = source;
   
% get days for derived plots for this subnet
days = subnetpf2days(subnet);
subnets.days = days;

% get stations/channels for subnet from $subnet.pf
[station, pointerToStations, existsSubnetPF] = subnetpf2station(subnet);
subnets.windstation = subnetpf2windstation(subnet);
    
% for each station/channel get longitude, latitude, samprate, calib and
% a response vector
numstations = length(station);
if numstations > 0
	for station_num = 1:numstations
	    print_debug(sprintf('Processing station %d: %s',station_num, station(station_num).name),3);
		st = db2stationmetadata(station(station_num).name, station(station_num).channel, timewindow.start);
		%station(station_num).samprate = st.samprate;
		%station(station_num).calib = st.calib;
		%station(station_num).units = st.units;
		%station(station_num).response = st.response;
		station(station_num).site = st.site;
		clear st;
	end

	%station = db2stationdistances(subnet, station);

	% Add the station structure to the subnets structure
	subnets.stations = station;

% Should call createsubnetmap independent of this function
%	createsubnetmap(subnet, station);

% This was to match sound files with spectrogram panels
%	subnet2stationlist(subnet, station);
	
end

clear station sta;
	    
print_debug(sprintf('< %s', mfilename),2);

