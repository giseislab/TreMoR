function [paths,PARAMS]=pf2PARAMS();
% [paths,PARAMS]=pf2PARAMS()

% create pointer to main parameter file
parametersfile = catpath('pf','parameters');

if exist([parametersfile,'.pf'], 'file')

	parameterspf = dbpf(parametersfile);
    
    % subnet names
    PARAMS.subnetnames = pfget_tbl(parameterspf, 'subnetnames');
    
    % modules
%   PARAMS.compute1mindata = pfget_num(parameterspf,'compute1mindata');  
%    PARAMS.plotspectrograms = pfget_num(parameterspf,'plotspectrograms'); 
%    PARAMS.detectAlarms = pfget_num(parameterspf,'detectAlarms'); 
 %   PARAMS.plot1mindata = pfget_num(parameterspf,'plot1mindata');     
  %  PARAMS.makeHTML = pfget_num(parameterspf,'makeHTML');        
  %  PARAMS.sound = pfget_num(parameterspf,'sound');        
  %  PARAMS.print = pfget_num(parameterspf,'print');         
    
    % paths
    paths.DBMASTER = pfget(parameterspf,'DBMASTER');
    paths.PFS = pfget(parameterspf,'PFS');
    paths.ONEMINDATA = pfget(parameterspf,'ONEMINDATA');
    paths.WEBDIR = pfget(parameterspf,'WEBDIR'); 
    paths.spectrograms = pfget(parameterspf,'spectrograms'); 

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

	print_debug('PARAMS setup OK',1)
else
	error(sprintf('%s: parameter file %s.pf does not exist',mfilename, parametersfile));
end


