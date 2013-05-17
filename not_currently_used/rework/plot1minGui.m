function [subnet, stations, timewindow, measure, onemin, h]=plot1minGui(snum,enum)
% plot1minGui(snum,enum,processId)
% A rather lame basic-GUI for plotting 1 min data

% global variables
global paths subnets;
subnets=subnetsetup('Redoubt',pwd);

subnet = subnets(1).name;
stations = subnets(1).stations;
for c=1:length(stations)
	disp(stations(c).name);
end
%i=[2 3 4];
%stations=stations(i);

if (nargin==2)
	timewindow.start = snum;
else
	
	% get utdnum
	enum = utnow;
	disp(['Time now is ',datestr(enum)]);
	
	% timewindow

	% Choose timewindow 
	choice=menu('real-time plotter:','last 20 minutes','last 2 hours','SinceMar23','last 3 days','TremorJan25','TremorJan30','TremorFeb5','TremorFeb10','FromFeb28','Quit'); 
	switch choice
		case 1, timewindow.start = enum-20/1440;
		case 2, timewindow.start = enum-120/1440;
		case 3, timewindow.start = datenum(2009,3,23,0,0,0);
		case 4, timewindow.start = enum-3;
		case 5, timewindow.start = datenum(2009,1,25,9,0,0), enum = datenum(2009,1,27,5,0,0);
		case 6, timewindow.start = datenum(2009,1,30,0,0,0), enum = datenum(2009,1,31,5,0,0);
		case 7, timewindow.start = datenum(2009,2,5,19,0,0), enum = datenum(2009,2,10,0,0,0);
		case 8, timewindow.start = datenum(2009,2,13,0,0,0);
		case 9, timewindow.start = datenum(2009,2,28,0,0,0);
		case 10, return;
	end

end
timewindow.stop = enum;

% A multi-dr plot? 
choice=menu('do you want a multi-dr plot?:', 'no', 'yes'); 
if choice==2
	thisstation = menu('choose station:', stations.name);
	stations = stations(thisstation);
	measure = {'dr';'drs';'tdr';'tdrs';'tmdr';'tmdrs'};
	
else

	% Choose measure 
	measures = {'rsam';'en';'bdisp';'sdisp';'tdDisp';'tdMedian';'tdPeak';'bf';'sf';'dr';'drs'; ...
		'tdr';'tdrs';'tmdr';'tmdrs';'cumulativersam2';'cumulativeenergy'};
	choice=menu('measure:',measures); 
	measure=measures{choice};

	% Choose stations? 
	choice=menu('choose stations?:', 'no', 'yes'); 
	if choice==2
		st = stations;
		clear stations;
		d = 1;
		for c=1:length(st)
			name = st(c).name;
			choice=menu(['do you want to plot ',name,'?:'], 'no', 'yes'); 
			if choice == 2
				stations(d) = st(c);
				d=d+1;
			end
		end
	end
end

yaxisTypeMenu = {'linear';'logarithmic'};
choice=menu('y-axis:', yaxisTypeMenu); 
yaxisType=yaxisTypeMenu{choice};

despikeOn=menu('remove non-correlated spikes? :', 'no', 'yes');

downsampleOn=menu('downsample the data?:', 'no', 'yes'); 

save drplotgui.mat subnet stations timewindow measure yaxisType despikeOn downsampleOn
[onemin,h]=plotDData4(subnet,stations,timewindow,measure,yaxisType,despikeOn-1, downsampleOn-1);
save






