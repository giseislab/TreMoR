function tremor_runalarm()
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime
enum = utnow;
for subnet_num=1:length(subnets)
	subnet = subnets(subnet_num).name;
	disp(sprintf('\n****** Starting %s at %s *****',subnet , datestr(now)));
	station = subnets(subnet_num).stations;
	if (PARAMS.detectAlarms == 1) 
		try
			detectAlarms(subnet, station, timewindow, PARAMS.measures(1), 'static');
                	detectAlarms(subnet, station, timewindow, PARAMS.measures(1), 'adaptive');
		catch
			disp('Alarm detection failed');
		end
	end
end
print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)


