function tremor_makesamplots()
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime
enum = utnow;
for subnet_num=1:length(subnets)
	subnet = subnets(subnet_num).name;
	disp(sprintf('\n****** Starting %s at %s *****',subnet , datestr(now)));
	station = subnets(subnet_num).stations;
	for plot_num=1:length(PARAMS.dayplots)
		tic;
		snum = enum - PARAMS.dayplots{plot_num};
		IMGBASE = sprintf('%s_%.1f', subnet, PARAMS.dayplots{plot_num});
		for measureNum = 1:length(PARAMS.measures)
			measure = PARAMS.measures{measureNum};
			plotsamwrapper(subnet, station, snum, enum, measure, 'despikeOn', false, 'downsampleOn', false, 'correctOn', false, 'reduceOn', false);
			IMGDIR = catpath(paths.spectrogram_plots, measure);
			saveImageFile(IMGDIR, IMGBASE, 90);
			close;
		end
		logbenchmark(mfilename, toc);
	end
end
print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)


