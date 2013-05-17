function save2wfmeas(scnl, dnum, data, meastype, units, dbname)
% SAVE2WFMEAS save regularly-sampled data to a Datascope wfmeas table (dbname.wfmeas).
% save2wfmeas(scnl, dnum, data, meastype, units, dbname)

% AUTHOR: Glenn Thompson, UAFGI
% $Date$
% $Revision$


if length(data)==0
	return;
end

sta = get(scnl, 'station');
chan = get(scnl, 'channel');

disp(sprintf('Will save data to %s',dbname));

if ~exist(dbname, 'file')
    dbcreate(dbname);
end

db = dbopen(dbname, 'r+');
db = dblookup_table(db, 'wfmeas');
for c=1:length(dnum)
    sepoch = datenum2epoch(dnum(c));
    %arid = dbnextid(db, 'arid');
    db.record = dbaddnull(db);
    %dbputv(db, 'sta', sta, 'chan', chan, 'meastype', meastype, 'filter', 'BW 0.5 3 15.0 3', 'time', sepoch, 'endtime', sepoch + 60, 'tmeas', sepoch+30, 'twin', 60, ...
    %    'val1', data(c), 'units1', units, 'arid', arid, 'auth', mfilename);
    dbputv(db, 'sta', sta, 'chan', chan, 'meastype', meastype, 'time', sepoch, 'endtime', sepoch + 60, 'tmeas', sepoch+30, 'twin', 60, ...
        'val1', data(c), 'units1', units, 'auth', mfilename);
end
dbclose(db);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dbcreate(dbname)
disp(sprintf('Creating %s',dbname));
fdesc = fopen(dbname, 'w');
fprintf(fdesc, '#\n');
fprintf(fdesc, 'schema css3.0\n');
fclose(fdesc);
flastid = fopen([dbname,'.lastid'], 'w');
fclose(flastid);
fwf = fopen([dbname,'.wfmeas'], 'w');
fclose(fwf);
