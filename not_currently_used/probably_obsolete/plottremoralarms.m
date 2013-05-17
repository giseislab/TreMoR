function plottremoralarms(subnet, station, timewindow, alarmtype, measure)
disp('> plottremoralarms');
IMGDIR = sprintf('alarms/%s/plots', alarmtype);
first3stations = station(1:3);

% load data
eval(sprintf('load alarms/%s/summary/%s.dat;',alarmtype, subnet));
eval(sprintf('alarmlog = %s;',subnet));
dnum=alarmlog(:,1);
utrigs = alarmlog(:,2);
atrigs = alarmlog(:,3);
alarmsent = alarmlog(:,4);

% alarm plot
close all;
figure;
plot1mindata(subnet, first3stations, timewindow, 'tmdr', 'logarithmic', 1, 1);
%plotgmean(subnet, first3stations, timewindow, measure, 0, 0);
hold on;
i = find(alarmsent == 1);
plot(dnum(i), zeros(length(i),1), 'ro');
dateticklabel('x');
title(sprintf('Tremor alarms & %s (cm^2)',measure));
fname = sprintf('%salarms',subnet);	
saveImageFile(IMGDIR, fname);

% triggers plot
hold off;
close all;
figure;
i = find(alarmsent==1);
length(i)
hold on;
plot(dnum(i), atrigs(i), 'go');
stem(dnum(i), utrigs(i), 'ro');
dateticklabel('x');
ylabel('Number of stations that triggered');
title('Tremor alarm triggers');
fname = sprintf('%striggers',subnet);
saveImageFile(IMGDIR, fname);

% thresholds plot
close all;
figure;
plotDData4(subnet, station, timewindow, alarmtype, 'logarithmic', 0, 0);
title('Thresholds');
fname = sprintf('%sthresholds',subnet);
dateticklabel('x');
saveImageFile(IMGDIR, fname);

disp('< plottremoralarms');
