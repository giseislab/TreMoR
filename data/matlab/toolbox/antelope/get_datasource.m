function ds=get_datasource(snum, enum);
global PARAMS 
% where to get the waveform data from?
ds=[];
dv = datevec(snum); yyyy = dv(1);
if strcmp(PARAMS.mode,'realtime')  
	DBWF = { ...
		%'/avort/modrun/db/archive'; ...
		sprintf('/aerun/sum/run/db/archive_%d/archive',yyyy); ...
		sprintf('/aerun/op/run/db/archive_%d/archive',yyyy); ...
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

