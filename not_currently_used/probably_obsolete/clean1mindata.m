function onemin = clean1mindata(onemin, despikeOn, downsampleOn);
% onemin = clean1mindata(onemin, despikeOn, downsampleOn)
% data should be loaded with loadSubnet1minData
% Glenn Thompson, 2009/08

warning off;
print_debug('> clean1mindata',1);

% set loop sizes
numdatasets = length(onemin);

% filter and downsample the data
for c=1:numdatasets

	days = onemin(c).enum - onemin(c).snum;
	
	if onemin(c).datafound && length(onemin(c).data)>10

		t = onemin(c).dnum;
		y = onemin(c).data;
		measure = onemin(c).measure;

		print_debug(sprintf('Filtering dataset %d: data length is %d',c,length(y)),2)

		% despike the data
		if despikeOn

			% remove single spikes
			y = removeSingleSpikes(y);

			% apply thresholds
			if ~iscell(measure)
				y = applyThreshold(y, measure);
			end

			% look for non-correlated spikes on different stations and remove them
		end

		% remove any non positive values
		y = removeNonPositive(y);


		% cumulative measurements
		if ~iscell(measure)
			if strfind(measure, 'cumulative')
				y = nancumsum(y);
			end
		end
		

		% downsample to screen resolution
		print_debug('Testing whether to downsample',1)
		if (~iscell(measure) && days > 1 && downsampleOn==1)
			choices = [2 5 10 30 60 120 240 360 ];
			choice=max(find(days*2 > choices));
			if ~isempty(choice) 
				[t, y]=downsamplegt(t, y, choices(choice));
				print_debug(sprintf('Downsampling data by %d', choices(choice)),2)
			end
		end

		print_debug(sprintf('Putting the filtered vectors back; length of data is now %d',length(y)),2)
		onemin(c).dnum = t;
		onemin(c).data = y;
	end

end



print_debug('< clean1mindata',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y=removeNonPositive(y)
% remove any values less than zero before taking log (shouldn't have any)
if any(y)
	y_ind = find(y <= 0.0);
	y(y_ind)=NaN;
end


function y=removeSingleSpikes(y)
y1 = y(1:end-2);
y2 = y(2:end-1);
y3 = y(3:end);
i1 = 1 + find(y2 > 3 * y1); 
i2 = 1 + find(y2 > 3 * y3);
i = intersect(i1, i2);
y(i)=NaN;



function y=applyThreshold(y, measure)
threshold = NaN;
if strfind(measure,'en')
	threshold = 1e-4;
end
if ~isnan(threshold)
	i = find(y > threshold);
	y(i)=NaN;
end

