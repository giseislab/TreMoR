function [paths,PARAMS,subnets]=pf2PARAMS();
% [paths,PARAMS,subnets]=pf2PARAMS()

% create pointer to main parameter file
parametersfile = matlab_extensions.catpath('pf','setup');

if exist([parametersfile,'.pf'], 'file')

    parameterspf = dbpf(parametersfile);
    
    % subnets
    subnet_tbl = pfget_tbl(parameterspf, 'subnets');
    for c=1:numel(subnet_tbl)
	fields = regexp(subnet_tbl{c}, '\s+', 'split');
	subnets(c).name = fields{1};
	subnets(c).source.latitude = fields{2};
	subnets(c).source.longitude = fields{3};
	subnets(c).radius = fields{4};
	subnets(c).use = fields{5};
    end

    % Maximum number of scnls to display in a spectrogram
    PARAMS.max_number_scnls = pfget(parameterspf, 'max_number_scnls');
    
    % Select channels to use according to this channel mask
    PARAMS.channel_mask = pfget(parameterspf, 'channel_mask');
    
    % paths (removed from setup.pf file 2013/04/22)
    %paths.DBMASTER = pfget(parameterspf,'DBMASTER');
    paths.DBMASTER = getenv('SITE_DB');
    %paths.PFS = pfget(parameterspf,'PFS');
    paths.PFS = 'pf';
    %paths.ONEMINDATA = pfget(parameterspf,'ONEMINDATA');
    paths.ONEMINDATA = getenv('ONEMINDATA');
    %paths.WEBDIR = pfget(parameterspf,'WEBDIR'); 
    paths.WEBDIR = sprintf('%s/TreMoR',getenv('INTERNALWEBPRODUCTS')); 
    %paths.spectrograms = pfget(parameterspf,'spectrograms'); 
    paths.spectrogram_plots = 'plots'; 

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

    % archive_datasource
    switch_to_archive_after_days = pfget(parameterspf, 'switch_to_archive_after_days'); 
    archive_datasources = pfget_tbl(parameterspf, 'archive_datasources');
    for c=1:numel(archive_datasources)
	fields = regexp(archive_datasources{c}, '\s+', 'split');
	PARAMS.archive_datasource(c).type = fields{1};
	PARAMS.archive_datasource(c).path = fields{2};
	if numel(fields)>2
		PARAMS.archive_datasource(c).port = fields{3};
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



