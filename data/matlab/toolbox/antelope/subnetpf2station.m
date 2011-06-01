function [station, pointerToStations, existsSubnetPF] = subnetpf2station(subnet);
%subnetpf2station reads a subnet pf and returns a station structure:
% station.name{}
% station.channel{}
% station.threshold()
% station.use()
%
% Glenn Thompson, 1998 - 2008

print_debug(sprintf('> %s', mfilename),5)

% initialise
station.name = {};
station.channel = {};
station.threshold = [];
station.use = [];

% open pointer to subnet parameter file
[pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);

if existsSubnetPF

	% get station list for this subnet from parameter file
	pointerToStations = pfget_arr(pointerToSubnetPF,'stations');
	stas = pfkeys(pointerToStations);
    
    	% for each station, get the corresponding channel, threshold and use
	for station_num = 1:length(stas)
        	sta = stas{station_num};
		pointerToStation = pfget_arr(pointerToStations,sta);
		station(station_num).name = sta;
  		station(station_num).channel = pfget(pointerToStation,'chan');
 		station(station_num).threshold = pfget(pointerToStation,'threshold');
		station(station_num).use = pfget(pointerToStation,'use');
	end

else
	pointerToStations = -1;
	station = [];
end
print_debug(sprintf('< %s', mfilename),5)



