function ds=get_datasource(timewindow);

% where to get the waveform data from?
ds=[];
if timewindow.start > utnow - 7
	DBWF='db/archive';
    if exist(DBWF,'file')
        ds = [ds datasource('antelope', DBWF)];
        ds = [ds datasource('antelope', [DBWF,'_%04d_%02d_%02d'], 'year','month','day')];
    else
        print_debug('No local datasource (paths.DBWF) found',3);
    end
end

% add the mig and bak system if requesting data within last 12 days (depth of archive)
if timewindow.start > (utnow - 12) 
  if exist('/sun/iwrun/mig/db/archive','dir')
	ds = [ds datasource('antelope', ...
	       '/sun/iwrun/mig/db/archive/archive_%04d_%02d_%02d',...
	       'year','month','day')];
  end
  if exist('/sun/iwrun/bak/db/archive','dir')
	ds = [ds datasource('antelope', ...
	       '/sun/iwrun/bak/db/archive/archive_%04d_%02d_%02d',...
	       'year','month','day')];
  end
end
% add the op system always as a last resort if requesting data since 1999
if timewindow.start > datenum(1999,6,1)
  if exist('/sun/iwrun/op/db/archive','dir')
	ds = [ds datasource('antelope', ...
	       '/sun/iwrun/op/db/archive/archive_%04d/archive_%04d_%02d_%02d',...
	       'year','year','month','day')];
  end
end
