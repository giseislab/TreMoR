function threshold2tremoralarm(subnet, station, timewindow, measure, alarmtype)
% threshold2tremoralarm(subnet, station, timewindow, measure, alarmtype)
disp('> threshold2tremoralarm');

global PARAMS paths numstations


% set up paths
paths.lastalarmfile = sprintf('state/%s%slastalarm.mat',alarmtype,subnet);
mkdir('state');
paths.alarmlog = sprintf('alarms/%s/summary/%s.dat', alarmtype, subnet);
mkdir(sprintf('alarms/%s/summary/', alarmtype, subnet));
paths.alarmMsgPath = sprintf('alarms/%s/messages',alarmtype);
mkdir(paths.alarmMsgPath);
paths.datadir = '/sun/iceweb/development/iceweb2/derivedData/';
paths.alarmdb = '/home/glenn/db/alarmdb';

% create descriptor if it does not exist already
if ~exist(paths.alarmdb, 'file')
	[base, dir] = basename(paths.alarmdb);
	if ~exist(dir, 'dir')
		mkdir(dir);
	end
	fout = fopen(paths.alarmdb, 'w');
	fprintf(fout, '#  Datascope Database Descriptor File\n');
	fprintf(fout, 'schema css3.0\n');
	fprintf(fout, 'dbpath /iwrun/op/run/dbmaster/{master_stations}:/avort/oprun/dbseg/{quakes}');
	fclose(fout);
end

% load the data
enum = timewindow.stop;
snum = timewindow.stop - 60/1440;
onemin = loadSubnet1minData(subnet, station, snum, enum, measure, paths.datadir);

% initialise
numtriggers = 0;
triggersForAlarmFraction = PARAMS.triggersForAlarmFraction; 
triggered=[];
m=[];
numstations = length(station);

% load last alarm time
if exist(paths.lastalarmfile, 'file')
	eval(sprintf('load %s',paths.lastalarmfile));
else
	lastalarmdnum = 0;
	signalLevels = zeros(length(station), 1); 
end
 
% adaptive threshold levels
if strcmp(alarmtype,'adaptive')
	halflife = 30 / 1440; % 30 minutes
	for c=1:numstations
		thresholds(c) =  station(c).threshold + ...
		(signalLevels(c) - station(c).threshold) * exp( - (enum - lastalarmdnum) / halflife);
	end
else % static
	halflife = 9999;
	for c=1:numstations
		thresholds(c) = station(c).threshold;
	end
end

% perform detections for each station
for stationNum = 1:numstations
	print_debug(sprintf('Checking %s',station(stationNum).name),2)
	dnum0 = onemin(stationNum).dnum;
	data0 = onemin(stationNum).data;
	[dnum0, data0, usedata] = clean_data(dnum0, data0);
	triggered(stationNum) = 0;
	usetriggered(stationNum) = 0;
	m(stationNum)=0;
	
	if (length(data0) > 20) % must have at least 20 minutes of data in last hour
%		disp(sprintf('Got enough data for %s',station(stationNum).name));		 

		[triggered(stationNum), m(stationNum)] = detectTrigger(dnum0, data0, thresholds(stationNum));
		if (isnan(triggered(stationNum))) 
			station(stationNum).use = 0;
		end

		dnum_trigger(stationNum) = dnum0(end);

	end
	use(stationNum) = min([station(stationNum).use usedata]);
	usetriggered(stationNum) = triggered(stationNum);
	if use(stationNum) == 0
		usetriggered(stationNum) = 0;
	end

	print_debug(sprintf('Station: %s, Triggered: %d, Use: %d',station(stationNum).name, triggered(stationNum), use(stationNum)),2)
end

% total number of triggers
numtriggers = nansum(usetriggered );
print_debug(sprintf('%d stations in use, %d triggers', sum(use), numtriggers),2);
end

% number of triggers needed
numtriggersThreshold = max([ (triggersForAlarmFraction * sum(use)) 1]);

% save summary file
alarmsent=0;
if(numtriggers >= numtriggersThreshold ) 
	tremoralarm2db(subnet, station, usetriggered, use, m, enum, alarmtype, measure);
	alarmsent=1;

	% update the last alarm file
	lastalarmdnum = enum;
	signalLevels = m;
	eval(sprintf('save %s lastalarmdnum signalLevels',paths.lastalarmfile));
end

% This is information used to create plots
if (alarmsent == 1)
	fout = fopen(paths.alarmlog, 'a');
	fprintf(fout,'%f %d %d %d\n',enum, numtriggers, nansum(triggered), alarmsent);
	fclose(fout);
end

disp('< threshold2tremoralarm');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dnum, data, use] = clean_data(dnum, data);
use = 1;
% remove any zeroes, NaNs or negatives
i = find(data > 0.01 & data < 99);
if (length(i)/length(dnum) < 0.66)
	use = 0;
end
dnum=dnum(i);
data=data(i);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [triggered, m] = detectTrigger(dnum, data, threshold)

triggered = NaN;
threshold_exceeded = 0;
trend = 0;

% Last 10 minutes
i = find(dnum > (dnum(end) - 20/1440) );
if (length(i) > 0)
	m = nanmedian(data(i));
	if (m > threshold)
		threshold_exceeded = 1;
	else
		triggered = 0;
	end

end

% Last hour
%y = detrend(data);
%z = data - y;
%if (z(end) > z(1) * 2)
%subplot(3,1,1), plot(data)
%subplot(3,1,2), plot(y)
%subplot(3,1,3), plot(z)
%drawnow;
%a=input('');
%	disp(sprintf('ratio = %.1f',z(end)/z(1)));
%	% positive trend in last hour
%	trend = 1;
%end
%trend =1;

try
	m0 = nanmedian(data(find(dnum < (dnum(end) - 20/1440) )));
catch
	m0 = m;
end

if (m > m0 * 3)
	disp(sprintf('ratio = %.1f',m/m0));
	trend = 1;
end

if (threshold_exceeded && trend)
	triggered = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tremoralarm2db(subnet, station, triggered, use, m, enum, alarmtype, measure);
global PARAMS paths numstations;

% write message file

alarmMsgBase = sprintf('%s%s.txt',subnet,datestr(enum,30));
alarmMsgFile = catpath(paths.alarmMsgPath, alarmMsgBase);
fam=fopen(alarmMsgFile,'w');
fprintf(fam,'ICEWEB ALARM at %s at %s\n',subnet,datestr(enum,31));
fprintf(fam,'%s > threshold at %d out of %d in use\n\n',measure,sum(triggered),sum(use));
fprintf(fam,'STA \tuse thrshld ..%s.. trg\n',measure);
for station_num = 1:numstations
	fprintf(fam,'%s:\t%3d %7.1f %7.1f %3d\n', ...
	station(station_num).name, use(station_num), station(station_num).threshold, m(station_num), triggered(station_num));
end
fclose(fam);

% write alarm row in alarms database
alarm2db(paths.alarmdb, 'tremor', sprintf('%s_%s',alarmtype,subnet), enum, sprintf('%s %s',subnet,datestr(enum,31)), paths.alarmMsgPath, alarmMsgBase)



 
