function station = db2stationdistances(subnet, station, snum)
% station = db2stationdistances(subnet, station)
% Calls get_source to get subnet coordinates
% Then computes station.distance for all station.name by calling get_station_coordinates
% and calculate_distance
% Glenn Thompson 2007
print_debug(sprintf('> %s', mfilename),4)
source = pf2source(subnet);
if ~exist('snum', 'var')
    snum = now;
end
% if source.latitude non-zero it means didn't find a match in places file, e.g. for Akutan. 
% In this case, station.distance loaded with readIceWebStations will not be overwritten
%source.latitude
if (source.latitude ~= 0)
	% we can do better than distance parameters in subnet files
	for c=1:length(station)
			site = db2stationcoordinates(station(c).name, datenum2epoch(snum));
            station(c).distance = distancegt([source.longitude source.latitude 0], [site.longitude site.latitude 0]);
	end
end
print_debug(sprintf('< %s', mfilename),4)

