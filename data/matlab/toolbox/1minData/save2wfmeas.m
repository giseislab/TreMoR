function save2wfmeas(sta, chan, dnum, data, meastype, units, fname)

% Author:
% 	Glenn Thompson, AVO, 2011 


if length(data)<1
	return;
end

global paths ;
print_debug(sprintf('> %s', mfilename),4)

if ~exist('fname','var')
    % write data
    dbname = [sta,'_',chan,'_',meastype];
    dbname = catpath(paths.ONEMINDATA, dbname);
else
    dbname = fname;
end
disp(sprintf('Will save data to %s',dbname));

if ~exist(dbname, 'file')
    dbcreate(dbname);
end

db = dbopen(dbname, 'r+');
db = dblookup_table(db, 'wfmeas');
for c=1:length(dnum)
    sepoch = datenum2epoch(dnum(c));
    arid = dbnextid(db, 'arid');
    db.record = dbaddnull(db);
    dbputv(db, 'sta', sta, 'chan', chan, 'meastype', meastype, 'filter', 'BW 0.5 3 15.0 3', 'time', sepoch, 'endtime', sepoch + 60, 'tmeas', sepoch+30, 'twin', 60, ...
        'val1', data(c), 'units1', units, 'arid', arid, 'auth', mfilename);
    %dbaddv(db, 'sta', sta, 'chan', chan, 'meastype', meastype, 'filter', 'BW 0.5 3 15.0 3', 'time', sepoch, 'endtime', sepoch + 60, 'tmeas', sepoch+30, 'twin', 60, ...
    %    'val1', data(c), 'units1', units, 'arid', arid, 'auth', mfilename);
end
dbclose(db);


print_debug(sprintf('< %s', mfilename),4)

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
