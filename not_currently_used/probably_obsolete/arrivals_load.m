function a = arrivals_load(dbname, expression)
% See also Mikes contributed_antelope/traveltime_and_ray_coverage/+ttimes/dbload.m
a.dnum = [];
a.snr_arrival = [];
a.sta = '';
a.chan = '';
a.arid = [];
a.iphase = {};
a.auth = {};
if ~exist(dbname, 'file')
    disp('No such database');
    return
end
db = dbopen(dbname, 'r');
db = dblookup_table(db, 'arrival');
if exist('expression', 'var')
    db = dbsubset(db, sprintf('%s',expression));
end
numarrivals = dbquery(db, 'dbRECORD_COUNT');
if numarrivals > 0
    [sta, time, arid, chan, iphase, snr, auth] = dbgetv(db, 'sta', 'time', 'arid', 'chan', 'iphase', 'snr', 'auth');
    a.dnum = epoch2datenum(time);
    a.snr_arrival = snr;
    if strcmp(class(sta),'cell')
        a.sta = sta{1};
        a.chan = chan{1};
    else % deal with case of just 1 arrival
        a.sta = sta;
        a.chan = chan;
    end
    a.arid = arid;
    a.iphase = iphase;
    a.auth = auth;
    clear time snr sta chan arid iphase auth;
else
    %disp('No arrivals');
end
dbclose(db);

