function [ax, g1, g2] = plotyy_eventrate_and_drs(subnet, station, snum, enum, datadir, params, parameter, threshold_mean)

% load the tmdrs data
onemin = loadSubnet1minData(subnet, station, snum, enum, 'tmdrs', datadir);

% what did we get
disp(sprintf('Number of data samples is %d', length(onemin)));

% downsample data
if (enum-snum>7)
	onemin.dnum = downsample(onemin.dnum, round(enum-snum));
	onemin.data = downsample(onemin.data, round(enum-snum));
else
	onemin.data = smooth(onemin.data, 30);
end



% load the swarm parameter data
if strcmp(parameter, 'event_rate')
	data1 = params.mean_rate;
	[dnum, data1] = dnumsubset(params.dnum, data1, snum, enum);
	data2 = params.median_rate;
	[dnum, data2] = dnumsubset(params.dnum, data2, snum, enum);	
	i = find(data1 >= threshold_mean);
	data = data1;
	data(i) = data2(i);
else
	eval(sprintf('data = params.%s(i);', parameter));
	[dnum, data] = dnumsubset(data, snum, enum);
end
data(find(isnan(data)))=0;

% plot the datasets
m = ceil((max(data) * 4/3) / 20) * 20 ;
[ax, g1, g2] = plotyygtmukesh( ...
                dnum, ...
                data, ...
                onemin.dnum, ...
                onemin.data, ...
                '', ...
                'log10', ...
                0:m/4:m, ...
                [0.01 0.1 1 10 100 ], ...
                'events/hour', ...
                'D_R_S (cm^2)' ...
      )






