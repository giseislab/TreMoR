function wfmeas2bob(dbname);
% This is a low level routine to load what data reside in a single
% wfmeas table file, and save them into bob format.
%
% Example:
%   wfmeas2bob('/iceweb2/1mindata/REF_EHZ_Dstd');
% Will produce a file like:
%   /iceweb2/1mindata/REF_EHZ_Dstd_2009
%
% Author:
% 	Glenn Thompson, AVO, 2011 

% 1. get basename of dbname
[bname,dname]=basename(dbname);
% 2. split into station, channel and meastype
i=findstr(bname,'_');
i0=1;
word={};
for c=1:length(i)
    word{c}=bname(i0:i(c)-1);
    i0=i(c)+1;
end
word{c+1}=bname(i0:end);
% 3. build a onemin.station structure out of station and channel
onemin.station.name = word{1};
onemin.station.channel = word{2};
onemin.measure = word{3};
   
% Set path to data file
if ~exist(dbname, 'file')
    disp(sprintf('%s not found',dbname));
    return;
end

db = dbopen(dbname, 'r');
db = dblookup(db, '', 'wfmeas', '', '');
db = dbsort(db, 'tmeas');
if dbquery(db, 'dbRECORD_COUNT') > 0
    [tmeas, val1, units1] = dbgetv(db, 'tmeas', 'val1', 'units1');
    dnum = epoch2datenum(tmeas);
    data = val1;
    write2bob(dnum, data, dbname);
else
   disp('No data found'); 
end
dbclose(db);






