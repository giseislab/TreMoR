function station = getStationsWithinDist(lon, lat, distkm, dbstations, maxsta)
% station = getStationsWithinDist(lon, lat, distkm, maxsta)
% gets all stations from master stations database within dist degrees of point described by [lon, lat]
% station = getStationsWithinDist('Okmok', [], distkm) gets stations
% within distkm degrees of 'Okmok'
% station distances returned in km, not degrees
global paths verbose;

if ~exist('maxsta', 'var')
	maxsta = 999;
end

if isstr(lon)
    [lon, lat] = readavovolcs(lon, '/avort/oprun/pf/avo_volcs.pf');
end

if ~exist('dbstations', 'var')
	dbstations = 'dbmaster/master_stations';
elseif isempty(dbstations)
	dbstations = 'dbmaster/master_stations';
end
	
db = dbopen(dbstations, 'r');
db = dblookup_table(db, 'site');
db = dbsubset(db, sprintf('distance(lon, lat, %.4f, %.4f)<%.4f',lon,lat,km2deg(distkm)));
db = dbsubset(db, sprintf('offdate == NULL'));
db2 = dblookup_table(db, 'sitechan');
db2 = dbsubset(db2, '(chan=~/[BES]H[ENZ]/  || chan=~/BDF/) && offdate == NULL');
db2 = dbjoin(db, db2);
db3 = dblookup_table(db, 'snetsta');
db3 = dbjoin(db2, db3);
%db3 = dbsubset(db3, 'snet=~/A[KTV]/');
latitude = dbgetv(db3, 'lat');
longitude = dbgetv(db3, 'lon');
elev = dbgetv(db3, 'elev');
staname = dbgetv(db3, 'sta');
channame = dbgetv(db3, 'chan');
net = dbgetv(db3, 'snet');
dbclose(db);

numstations = length(latitude);
for c=1:length(latitude)
	%stadist(c) = calculate_distance(lon, lat, longitude(c), latitude(c));
    stadist(c) = deg2km(distance(lat, lon, latitude(c), longitude(c)));
end

% order the stations by distance
[y,i]=sort(stadist);
c=1;
while ((c<=numstations) && (stadist(i(c)) < distkm))
	station(c).name = staname{i(c)};
	station(c).channel = channame{i(c)};
	station(c).scnl = scnlobject(station(c).name, station(c).channel, net{i(c)});
	station(c).site.lon = longitude(i(c));
	station(c).site.lat = latitude(i(c));
	station(c).site.elev = elev(i(c));
	station(c).distance = stadist(i(c));
	c = c + 1;
end

% remove any duplicate stations
%[~,j]=unique({station.name});
%station = station(sort(j));

% limit the number of stations
numstations = min([maxsta numel(station)]);
station = station(1:numstations);

