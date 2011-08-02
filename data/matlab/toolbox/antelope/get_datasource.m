function ds=get_datasource(snum, enum);

% where to get the waveform data from?
ds=[];

DBWF = { ...
	'/avort/modrun/db/archive'; ...
%	'/avort/devrun/db/archive'; ...
	'/avort/oprun/db/archive'; ...
	'/iwrun/mig/db/archive'; ...
	'/iwrun/bak/db/archive'; ...
	'/iwrun/op/db/archive'; ...
};

for c=1:length(DBWF)
	thisdbwf = DBWF{c};
    	if exist(thisdbwf,'file') 
		if snum > utnow - 3
			wfdiscenum = wfdisc2enum(thisdbwf);
			if wfdiscenum > enum
        			ds = [ds datasource('antelope', thisdbwf)];
			end
		else
			if strfind(thisdbwf, 'avort')
				next;
			end
        		ds = [ds datasource('antelope', [thisdbwf,'_%04d_%02d_%02d'], 'year','month','day')];
		end
	end
end
