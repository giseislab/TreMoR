function station = getStationsWithinDist(lon, lat, dist, dbstations, maxsta)
% station = getStationsWithinDist(lon, lat, dist)
% gets all stations from master stations database within dist km of point described by [lon, lat]
% uses paths.DBMASTER
% sets channel to EHZ unless name matches RDWB or RDJH - could be improved
global paths;

print_debug(sprintf('> %s', mfilename),1)
db = dbopen(dbstations, 'r');
db = dblookup_table(db, 'site');
db2 = dbsubset(db, sprintf('offdate == NULL'));
%db2 = dbsubset(db2, sprintf('distance(%f, %f, lat, lon)<%f',lat, lon, km2deg(dist) )  );
%db2 = dbsubset(db2, distance(slat, slon, lat, lon)<km2deg(dist) ); 

latitude = dbgetv(db2, 'lat');
longitude = dbgetv(db2, 'lon');
elev = dbgetv(db2, 'elev');
staname = dbgetv(db2, 'sta');
dbclose(db);

numstations = length(latitude);
for c=1:length(latitude)
	stadist(c) = deg2km(distance(lat, lon, latitude(c), longitude(c)));
end

% order the stations by distance
[y,i]=sort(stadist);
c=1;
numstations = min([numstations maxsta]);
while ((c<=numstations) && (stadist(i(c)) < (dist)))
	station(c).name = staname{i(c)};
	station(c).longitude = longitude(i(c));
	station(c).latitude = latitude(i(c));
	station(c).elevation = elev(i(c));
	station(c).distance = stadist(i(c));
	c = c + 1;
end
print_debug(sprintf('< %s', mfilename),1)


