function make1minPlots(subnet, station, enum, days)
% make1minPlots(subnet, station, enum, days)

global paths PARAMS;
print_debug(sprintf('> %s', mfilename),1)


% loop over plots
measures = PARAMS.measures;

% if no drplots were requested, end function
if ~isempty(days)

	% loop for each requested plot (several timescales may have been requested)
	for plot_num=1:length(days)

		% work out where this data begins
		snum = enum - days{plot_num};
	
		% get correct name
		IMGBASE = sprintf('%s_%.1f', subnet, days{plot_num});

		for measureNum = 1:length(measures)
			measure = measures{measureNum};

			% close previous plots
			close all;
		
			% Produce logarithmic reduced displacement plot
			print_debug(sprintf('Calling plotDData for %d days and measure %s',days{plot_num}, measure),1)
			%h = figure;
			%plot1mindata_wrapper(subnet, station, timewindow.start, timewindow.stop, measure, 'logarithmic', 0, 0, paths.ONEMINDATA, h);
            [fh,ah,onemin]=plotoneminwrapper(subnet, station, snum, enum, measure, 'despikeOn', false, 'downsampleOn', false, 'correctOn', false, 'reduceOn', false);
			IMGDIR = catpath(paths.WEBDIR, 'plots', measure);
			saveImageFile(IMGDIR, IMGBASE, 90);

			close all;
%			disp('Linear plot');
%			plot1mindata(subnet, station, timewindow, measure, 'linear', 1, 1);
%			fname = sprintf('%slin',IMGBASE);
%			title('Reduced Displacement (cm^2)');
%			saveImageFile(IMGDIR, fname, 90);


		end

	end
else
	disp('No days to plot');	
end
print_debug(sprintf('< %s', mfilename),1)

