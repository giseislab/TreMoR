function threshold2tremoralarm(subnet, station, timewindow, measure, alarmtype)
% threshold2tremoralarm(subnet, station, timewindow, measure, alarmtype)
global PARAMS

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
	% 20121101 GTHO: Replacing basename with fileparts
	%[base, dir] = basename(paths.alarmdb);
	[dir, base] = fileparts(paths.alarmdb);
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
for c=1:numel(station)
	samarray(c) = sam(subnet, station, snum, enum, measure, paths.datadir);
end


% initialise
numtriggers = 0;
triggersForAlarmFraction = PARAMS.triggersForAlarmFraction; 
triggered=[];
m=[];
numstations = numel(samarray);

% load last alarm time
if exist(paths.lastalarmfile, 'file')
	eval(sprintf('load %s',paths.lastalarmfile));
else
	lastalarmdnum = 0;
	signalLevels = zeros(length(station), 1); 
end

 
% threshold levels
if strcmp(alarmtype,'adaptive')
	halflife = 30 / 1440; % 30 minutes
else
	halflife = 9999; % static threshold
end
	for c=1:numstations
		% compute threshold
	thresholds(c) =  thresholds(c) + ...
	(signalLevels(c) - thresholds(c)) * exp( - (samarray(c).dnum(end)) - lastalarmdnum) / halflife);
end

		
% Determine tremor episodes by some method

% METHOD 1: Looks at last 10 minutes, requires at least 50% increase and above threshold
%sam2tremorepisode_oldalgorithm(samarray, thresholds);

% METHOD 2: on and off thresholds
for c=1:numstations
	te=sam2tremorepisode(samarray(c), thresholds(c), threshoff(c), duration(c));
end

%%%%%%% GTHO 20121029: Everything below needs to be examined as I haven't gone through it yet
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
		
% save the thresholds in an ascii file
%threshfile = sprintf('alarms/%s/thresholds/%sthresholds.dat',alarmtype, subnet);
%fth = fopen(threshfile, 'a');
%fprintf(fth, '%f ',timewindow.stop);
%for c=1:length(thresholds)
%	fprintf(fth, '%5.1f ',thresholds(c));
%end
%fprintf(fth, '\n');
%fclose(fth);

% OK, now create plots
%timewindow.start = timewindow.stop - 3;
%	if ((alarmsent == 1) && strcmp(PARAMS.mode, 'realtime'))
%	try
%		plotalarms(subnet, station, timewindow, alarmtype, measure);
%	catch
%		disp('Could not plot alarm figures');
%	end
%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sam2tremorepisode_oldalgorithm(samarray)	
		numstations = numel(samarray, thresholds);
		for c=1:numstations	
			use(c) = true;

			% filter out non-positive values
			i = find(samarray(c).data > 0.01 & samarray(c).data < 99);
			if (length(i)/length(dnum) < 0.66)
				use(c) = false;
			end
			dnum0=samarray(c).dnum(i);
			data0=samarray(c).data(i);
			triggered(c) = false;
			m(c)=NaN;
			dnum_trigger(c) = NaN;

			if (length(data0) > 20) % must have at least 20 minutes of data in last hour
				threshold_exceeded(c) = false;
				trend(c) = false;

				% Last 10 minutes
				i = find(dnum0 > (dnum0(end) - 10/1440) );
				if (length(i) > 0)
					m(c) = nanmean(data(i));
					if (m(c) > thresholds(c))
						threshold_exceeded(c) = true;
					end

				end

				% Trend method 1
				y = detrend(data0);
				z = data0 - y;
				if (z(end) > z(1) * 1.5)
					% positive trend in last hour - more than 50% increase
					trend(c) = true;
				end

				% Trend method 2
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
					triggered(c) = true;
				end

				dnum_trigger(c) = dnum0(end);
	
			end	

			libgt.print_debug(sprintf('Station: %s, Triggered: %d, Use: %d',station(c).name, triggered(c), use(c)),2);
		end	

