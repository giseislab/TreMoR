function [dnum, data, datafound] = load_wfmeas(scnl, snum, enum, meastype, dbname);
% LOAD_WFMEAS Load data from a wfmeas table (dbname.wfmeas) corresponding to scnl, time range, meastype
% [dnum, data, datafound] = load_wfmeas(scnl, snum, enum, meastype, dbname)

% AUTHOR: Glenn Thompson, UAFGI
% $Date$
% $Revision$


% initialise output variables
dnum = [];
data = [];
datafound = false;
units = '';

sta = get(scnl, 'station');
chan = get(scnl, 'channel');

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
    dnum = epoch2datenum(tmeas);
    data = val1;
    units = units1{1};
    datafound=true;
end



