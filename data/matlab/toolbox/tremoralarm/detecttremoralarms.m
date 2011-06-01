function detecttremoralarms(subnet, station, timewindow, measure, alarmtype, dnum, data)
% detecttremoralarms(subnet, station, timewindow, measure, alarmtype, dnum, data)
disp('> detecttremoralarms');

%timewindow.stop = timewindow.stop + 30/86400; % make sure it counts the 10 minute mark
%timewindow.start = timewindow.start + 30/86400; % make sure it counts the 1 minute mark
global PARAMS verbose numstations
numstations = length(station);

%disp(sprintf('Testing %s vs. threshold values',measure));
numtriggers = 0;
tw.stop = timewindow.stop;
tw.start = timewindow.stop - 60/1440;
if ~exist('data','var')
	[dnum, data] = loadSubnetDerivedData(subnet, station, tw, measure);
	% should i be calling filterdata instead?
end
triggersForAlarmFraction = PARAMS.triggersForAlarmFraction; 

triggered=[];
m=[];

% load last alarm time
lastalarmfile = sprintf('state/%s%slastalarm.mat',alarmtype,subnet);
if exist(lastalarmfile, 'file')
	eval(sprintf('load %s',lastalarmfile));
else
	lastalarmdnum = 0;
	signalLevels = zeros(length(station), 1); 
end
 
% adaptive threshold levels
if strcmp(alarmtype,'adaptive')
	halflife = 30 / 1440; % 30 minutes
	for c=1:numstations
		thresholds(c) =  station(c).threshold + ...
		(signalLevels(c) - station(c).threshold) * exp( - (timewindow.stop - lastalarmdnum) / halflife);
	end
else % static
	halflife = 9999;
	for c=1:numstations
		thresholds(c) = station(c).threshold;
	end
end

for stationNum = 1:numstations
	print_debug(sprintf('Checking %s',station(stationNum).name),2)
	dnum0 = dnum{stationNum};
	data0 = data{stationNum};
	[dnum0,data0]=clean_data(dnum0,data0);
	triggered(stationNum) = 0;
	usetriggered(stationNum) = 0;
	m(stationNum)=0;
	
	if (length(data0) > 20) % must have at least 20 minutes of data in last hour
%		disp(sprintf('Got enough data for %s',station(stationNum).name));		 

		[triggered(stationNum), m(stationNum)] = detectTrigger(dnum0, data0, thresholds);
		if (isnan(triggered(stationNum))) 
			station(stationNum).use = 0;
		end

		dnum_trigger(stationNum) = dnum0(end);

		
	
	end
	use(stationNum) = station(stationNum).use;
	usetriggered(stationNum) = triggered(stationNum);
	if use(stationNum) == 0
		usetriggered(stationNum) = 0;
	end

	print_debug(sprintf('Station: %s, Triggered: %d, Use: %d',station(stationNum).name, triggered(stationNum), use(stationNum)),2);
end

% save the thresholds in a binary file
for stationNum = 1:numstations
	saveBinary(subnet, station(stationNum).name, timewindow.stop, thresholds(c), alarmtype);
end

% save the thresholds in an ascii file
threshfile = sprintf('alarms/%s/thresholds/%sthresholds.dat',alarmtype, subnet);
fth = fopen(threshfile, 'a');
fprintf(fth, '%f ',timewindow.stop);
for c=1:length(thresholds)
	fprintf(fth, '%5.1f ',thresholds(c));
end
fprintf(fth, '\n');
fclose(fth);


numtriggers = nansum(usetriggered );
print_debug(sprintf('%d stations in use, %d triggers', sum(use), numtriggers),2)

numtriggersThreshold = max([ (triggersForAlarmFraction * sum(use)) 1]);

% save summary file
alarmsent=0;
if(numtriggers >= numtriggersThreshold ) 
	tremoralarm2db(subnet, station, usetriggered, use, m, timewindow.stop, alarmtype, measure);
	alarmsent=1;

	% update the last alarm file
	lastalarmdnum = timewindow.stop;
	signalLevels = m;
	eval(sprintf('save %s lastalarmdnum signalLevels',lastalarmfile));
end

% HERE ADD CODE TO SAVE TIMEWINDOW.STOP, NUMTRIGGERS, SUM(TRIGGERED), ALARMSENT (1 OR 0)
% This is information used to create plots
if (alarmsent == 1)
	alarmlog = sprintf('alarms/%s/summary/%s.dat', alarmtype, subnet);
	fout = fopen(alarmlog, 'a');
	fprintf(fout,'%f %d %d %d\n',timewindow.stop, numtriggers, nansum(triggered), alarmsent);
	fclose(fout);
end


% OK, now create plots
if strcmp(subnet, 'Redoubt')
	timewindow.start = datenum(2009,1,23); %alarmsent=1;
else
	timewindow.start = timewindow.stop - 3;
end
if ((alarmsent == 1) && strcmp(PARAMS.mode, 'realtime'))
	try
		plotalarms(subnet, station, timewindow, alarmtype, measure);
	catch
		disp('Could not plot alarm figures');
	end
end
disp('< detecttremoralarms');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dnum,data]=clean_data(dnum,data);
% remove any zeroes, NaNs or negatives
i = find(data > 0 & data < 99999);
dnum=dnum(i);
data=data(i);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [triggered, m] = detectTrigger(dnum, data, threshold)

triggered = NaN;
threshold_exceeded = 0;
trend = 0;

% Last 10 minutes
i = find(dnum > (dnum(end) - 10/1440) );
if (length(i) > 0)
	m = nanmean(data(i));
	if (m > threshold)
		threshold_exceeded = 1;
	else
		triggered = 0;
	end

end

% Last hour
y = detrend(data);
z = data - y;
if (z(end) > z(1) * 1.5)
	% positive trend in last hour
	trend = 1;
end
%trend =1;

if (threshold_exceeded && trend)
	triggered = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tremoralarm2db(subnet, station, triggered, use, m, enum, alarmtype, measure);
global PARAMS paths numstations;

% write message file
alarmMsgPath = sprintf('alarms/%s/messages',alarmtype);
alarmMsgBase = sprintf('%s%s.txt',subnet,datestr(enum,30));
alarmMsgFile = catpath(alarmMsgPath, alarmMsgBase);
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
alarm2db('dbalarm/dbalarm', 'tremor', sprintf('iceweb_tremor_%s',subnet), enum, sprintf('%s %s',subnet,datestr(enum,31)), alarmMsgPath, alarmMsgBase)



 
