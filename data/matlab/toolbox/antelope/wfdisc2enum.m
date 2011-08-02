function endtime=wfdisc2enum(dbwf) 
db = dbopen(dbwf, 'r'); 
db = dblookup_table(db, 'wfdisc');
db = dbsubset(db, 'chan=~/EHZ/');
db = dbsort(db, 'endtime');
nrecs = dbquery(db, 'dbRECORD_COUNT');
if nrecs > 0
	db.record = nrecs-1;
	endtime = epoch2datenum(dbgetv(db, 'endtime'));
else
	disp(sprintf('No valid data rows in %s',dbwf));
	endtime = 0;
end
