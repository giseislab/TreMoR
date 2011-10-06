function ds=get_datasource(snum, enum);

% where to get the waveform data from?
ds=[];

DBWF = { ...
	'/avort/modrun/db/archive'; ...
	'/avort/devrun/db/archive'; ...
	'/aerun/mig/db/archive/archive'; ...
	'/aerun/sum/db/archive/archive'; ...
	'/aerun/op/db/archive/archive'; ...
};

for c=1:length(DBWF)
	thisdbwf = DBWF{c};
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

