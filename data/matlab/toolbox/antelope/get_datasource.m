function ds=get_datasource(snum, enum);

% where to get the waveform data from?
ds=[];
if snum > utnow - 7
	DBWF='db/archive';
    if exist(DBWF,'file')
        ds = [ds datasource('antelope', DBWF)];
        ds = [ds datasource('antelope', [DBWF,'_%04d_%02d_%02d'], 'year','month','day')];
    else
        print_debug('No local datasource found',3);
    end
end

% add the mig and bak system if requesting data within last 12 days (depth of archive)
if snum > (utnow - 12) 
  if exist('/iwrun/mig/db/archive','dir')
	ds = [ds datasource('antelope', ...
	       '/iwrun/mig/db/archive/archive_%04d_%02d_%02d',...
	       'year','month','day')];
  end
  if exist('/iwrun/bak/db/archive','dir')
	ds = [ds datasource('antelope', ...
	       '/iwrun/bak/db/archive/archive_%04d_%02d_%02d',...
	       'year','month','day')];
  end
end
% add the op system always as a last resort if requesting data since 1999
if snum > datenum(1999,6,1)
  if exist('/iwrun/op/db/archive','dir')
	ds = [ds datasource('antelope', ...
	       '/iwrun/op/db/archive/archive_%04d/archive_%04d_%02d_%02d',...
	       'year','year','month','day')];
  end
end
