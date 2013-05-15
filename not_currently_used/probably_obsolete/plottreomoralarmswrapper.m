function plottremoralarmswrapper(subnet, snum, enum, pid, measure)
% plottremoralarmswrapper(subnet, snum, enum, pid, measure)
disp('> plottremoralarmswrapper')
	warning off;
	global processId PARAMS paths;
	processId = pid;
	cd(getenv('ICEWEB2_RUN'));
	eval(['load iceweb',num2str(processId),'.mat']);
	station = subnets(1).stations;
	timewindow.start = snum;
	timewindow.stop = enum;
	plottremoralarms(subnet, station, timewindow, 'static', measure);
	plottremoralarms(subnet, station, timewindow, 'adaptive', measure);
disp('< plottremoralarmswrapper')
