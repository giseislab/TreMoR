function ds=get_datasource(snum, enum);
global PARAMS 
% where to get the waveform data from?
ds=[];
dv = datevec(snum); yyyy = dv(1);
if strcmp(PARAMS.mode,'realtime')  
	DBWF = { ...
		%'/avort/modrun/db/archive'; ...
		sprintf('/aerun/sum/run/db/archive_%d/archive',yyyy); ...
		%sprintf('/aerun/op/run/db/archive_%d/archive',yyyy); ...
	};
else

	if snum>now-7
		DBWF = { ...
			'/avort/devrun/db/archive'; ...
			sprintf('/aerun/sum/run/db/archive_%d/archive',yyyy); ...
			sprintf('/aerun/op/run/db/archive_%d/archive',yyyy); ...
		};
	else
                DBWF = { ...
			sprintf('/aerun/sum/run/db/archive_%d/archive',yyyy); ...
			sprintf('/aerun/op/run/db/archive_%d/archive',yyyy); ...
                };
	end
end

for c=1:length(DBWF)
	thisdbwf = DBWF{c}
	if strfind(thisdbwf, 'avort')
    		if exist(thisdbwf,'file') 
			wfdiscenum = wfdisc2enum(thisdbwf);
			disp(datestr(wfdiscenum,31));
			disp(datestr(enum,31));
			if wfdiscenum > enum
				fprintf('Adding datasource %s\n',thisdbwf);
        			ds = [ds datasource('antelope', thisdbwf)];
			else
				fprintf('No data in datasource %s since %s. Looking for data to %s\n',thisdbwf,datestr(wfdiscenum),datestr(enum));
			end
		end
	else
        	ds = [ds datasource('antelope', [thisdbwf,'_%04d_%02d_%02d'], 'year','month','day')];
	end
end

function endtime=wfdisc2enum(dbwf) 
db = dbopen(dbwf, 'r'); 
db = dblookup_table(db, 'wfdisc');
db = dbsubset(db, 'chan=~/EHZ/');
db = dbsort(db, 'endtime');
nrecs = dbquery(db, 'dbRECORD_COUNT');
if nrecs > 0
	db.record = nrecs-1;
	endtime = epoch2datenum(dbgetv(db, 'endtime'));
	disp(sprintf('Latest waveform data in %s are at time %s',dbwf,datestr(endtime)))
else
	disp(sprintf('No valid data rows in %s',dbwf));
	endtime = 0;
end