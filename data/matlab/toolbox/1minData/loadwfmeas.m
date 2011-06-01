function onemin = loadwfmeas(station, snum, enum, meastype, datadir);
% onemin = loadwfmeas(station, snum, enum, meastype, datadir);

% Output:
%	onemin.dnum 
%	onemin.data
%	onemin.datafound
%	onemin.station.name
%	onemin.snum
%	onemin.enum
%	onemin.meastype
%
% Author:
% 	Glenn Thompson, AVO, 2011 

% initialise output variables
onemin.station.name = station(1).name;
onemin.channel = station(1).channel;
onemin.snum = snum;
onemin.enum = enum;
onemin.measure = meastype;
onemin.dnum=[];
onemin.data=[];
onemin.datafound=0;
onemin.units=[];

sta = station(1).name;
chan = station(1).channel;

  
   
% Set path to data file
dbname = [station(1).name,'_',station(1).channel,'_',meastype];
dbname = catpath(datadir, dbname);
if ~exist(dbname, 'file')
    disp(sprintf('%s not found',dbname));
    return;
end

expression = sprintf('(sta == "%s") && (chan =="%s") && (tmeas >= %f) && (tmeas <= %f) && (meastype == "%s")',sta, chan, datenum2epoch(snum), datenum2epoch(enum), meastype);

db = dbopen(dbname, 'r');
db = dblookup(db, '', 'wfmeas', '', '');
db = dbsubset(db, expression);
db = dbsort(db, 'tmeas');
if dbquery(db, 'dbRECORD_COUNT') > 0
    [tmeas, val1, units1] = dbgetv(db, 'tmeas', 'val1', 'units1');
    onemin.dnum = epoch2datenum(tmeas);
    onemin.data = val1;
    onemin.units = units1{1};
    onemin.datafound=1;
end



