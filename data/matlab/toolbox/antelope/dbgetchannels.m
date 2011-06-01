function channels=dbgetchannels(sta, dbstations)
global paths
print_debug(sprintf('> %s', mfilename),1)
db = dbopen(dbstations, 'r');
db = dblookup_table(db, 'sitechan');
db2 = dbsubset(db, sprintf('offdate == NULL  && sta == "%s"',sta));

channels = dbgetv(db2, 'chan');
%for c=1:length(chan)
%	channels(c).name = chan(c);
%end

if ~iscell(channels)
    channels = {channels};
end

dbclose(db);