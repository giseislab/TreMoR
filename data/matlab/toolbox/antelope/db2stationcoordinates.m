function site = db2stationcoordinates(staname, epochdate);
% SITE = db2stationcoordinates(STANAME, EPOCHDATE) returns a structure containing the 
% longitude, latitude and elevation of station STANAME by reading the master
% stations database.
% If EPOCHDATE is given, ondate & offdate are checked against this for a
% match. Otherwise, only currently defined sites - records with a null offdate - are matched.
%
% Note: for this function to work the variable paths.DBMASTER must be set
% to the location of your master stations database
%
% See also Kent Lindquist's 'Antelope Toolbox for Matlab' Tutorial
%
% Glenn Thompson, 2008-03-28
print_debug(sprintf('> %s', mfilename),4)
site.latitude = NaN;
site.longitude = NaN;
site.elev = NaN;
global paths;
dbstations = 'dbmaster/master_stations';
if isfield(paths,'DBMASTER')
    if exist(paths.DBMASTER,'file')
        dbstations = paths.DBMASTER;
    end
end

db = dbopen(dbstations, 'r');
db = dblookup_table(db, 'site');
print_debug(sprintf('Processing %s',staname),4);
if exist('epochdate', 'var')
    db2 = dbsubset(db, sprintf('(sta == "%s") && (ondate <= %f) && (offdate >= %f)',staname,epochdate,epochdate));
    if dbquery(db2, 'dbRECORD_COUNT')==0
        db2 = dbsubset(db, sprintf('(sta == "%s") && (ondate <= %f) && (offdate == NULL)',staname,epochdate));
    end
    if dbquery(db2, 'dbRECORD_COUNT')==0
        db2 = dbsubset(db, sprintf('sta == "%s" && offdate == NULL',staname));
    end
    
else
    db2 = dbsubset(db, sprintf('sta == "%s" && offdate == NULL',staname));
end
if dbquery(db2, 'dbRECORD_COUNT') > 0
	site.latitude = dbgetv(db2, 'lat');
	site.longitude = dbgetv(db2, 'lon');
	site.elev = dbgetv(db2, 'elev');
end
dbclose(db);
print_debug(sprintf('< %s', mfilename),4)
