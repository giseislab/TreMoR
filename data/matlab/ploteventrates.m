%function ploteventrates()
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(utnow,31)),1)
load pf/tremor_runtime.mat
dbroot='/net/chinook/avort/oprun/events/optimised/events';

% loop over all subnets
for subnet_num=1:length(subnets)
	close all;
        subnet = subnets(subnet_num).name;
	lat = subnets(subnet_num).source.latitude; 
	lon = subnets(subnet_num).source.longitude; 
	expr = sprintf('deg2km(distance(%f, %f, lat, lon))<30.0',lat,lon)
	try
		cobj = catalog(dbroot,  'antelope', 'dbeval', expr);
		try
			erobj = eventrate(cobj, 1/24);
			try
				plot(erobj, 'metric', {'mean_rate';'median_rate';'cum_mag'})
			catch
				plot(erobj, 'metric', {'mean_rate';'cum_mag'})
			end
			saveImageFile(sprintf('www/plots/eventrate_%s.png',subnet), 200);
		end
	end
end
print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
 


