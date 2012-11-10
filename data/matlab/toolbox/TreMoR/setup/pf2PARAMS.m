function [paths,PARAMS]=pf2PARAMS();
% [paths,PARAMS]=pf2PARAMS()

% create pointer to main parameter file
parametersfile = matlab_extensions.catpath('pf','parameters');

if exist([parametersfile,'.pf'], 'file')

	parameterspf = dbpf(parametersfile);
    
    % subnet names
    PARAMS.subnetnames = pfget_tbl(parameterspf, 'subnetnames');
    
    % paths
    paths.DBMASTER = pfget(parameterspf,'DBMASTER');
    paths.PFS = pfget(parameterspf,'PFS');
    paths.ONEMINDATA = pfget(parameterspf,'ONEMINDATA');
    paths.WEBDIR = pfget(parameterspf,'WEBDIR'); 
    paths.spectrograms = pfget(parameterspf,'spectrograms'); 

    % datasource
    datasources = pfget_tbl(parameterspf, 'datasources');
    for c=1:numel(datasources)
	fields = regexp(datasources{c}, '\s+', 'split');
	PARAMS.datasource(c).type = fields{1};
	PARAMS.datasource(c).path = fields{2};
	if numel(fields)>2
		PARAMS.datasource(c).port = fields{3};
	end
    end

    % waveform processing
	lowcut	 = pfget_num(parameterspf,'lowcut');
	highcut	 = pfget_num(parameterspf,'highcut');
	npoles	 = pfget_num(parameterspf,'npoles');
    PARAMS.filterObj = filterobject('b',[lowcut highcut],npoles);
    
    % Spectrograms
	PARAMS.spectralobject = spectralobject( ...
		pfget_num(parameterspf,'nfft'), ...
		pfget_num(parameterspf,'overlap'), ...
		pfget_num(parameterspf,'max_freq'), ...
		[ pfget_num(parameterspf,'blue') pfget_num(parameterspf,'red')] ...
	);

    % Derived data
	PARAMS.surfaceWaveSpeed = pfget_num(parameterspf,'surfaceWaveSpeed');
	PARAMS.df        = pfget_num(parameterspf, 'df');
    	PARAMS.f        = 0:PARAMS.df:50;
	PARAMS.measures = pfget_tbl(parameterspf, 'measures');
	PARAMS.dayplots = pfget_tbl(parameterspf, 'dayplots');
    
 	% Alarm system
	PARAMS.triggersForAlarmFraction = pfget_num(parameterspf,'triggersForAlarmFraction');

	debug.print_debug('PARAMS setup OK',1)
else
	error(sprintf('%s: parameter file %s.pf does not exist',mfilename, parametersfile));
end



