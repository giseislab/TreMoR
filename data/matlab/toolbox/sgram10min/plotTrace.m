function plotTrace(tracePosition, data, freqSamp, Xtickmarks, timewindow);
%tracePosition
%sizedata=size(data)
%freqSamp
%Xtickmarks

snum =timewindow.start;

% set axes position
axes('position',tracePosition);

% trace time vector - bins are ~0.01 s apart (not 5 s as for spectrogram time)
% not really worthwhile plotting more than 1000 points on the screen
dnum = ((1:length(data))./freqSamp)/86400 + snum;
timeDiffInMins = (dnum(end) - dnum(1)) * 1440;
len = length(data);
nsecs = 600; % number of seconds before downsampling occurs
binsize = ceil(len/(nsecs * freqSamp));

if (binsize > 1) 
	if (timeDiffInMins <= 10) % up to 1 hour of data
		disp(sprintf('Downsampling trace by factor %d with mean method',binsize))
		%data = abs(data); % have to rectify before averaging it out
		[dnum, data] = downsamplegt(dnum, data, binsize);
	else % more than 1 hour of data
		disp(sprintf('Downsampling trace by factor %d with decimate method',binsize))
		i = 1:binsize:len;
		dnum = dnum(i);
		data = data(i);
	end
end
% plot seismogram
data(find(data==0))=NaN;
traceHandle = plot(dnum, data);

% set properties
set (traceHandle,'LineWidth',[0.01],'Color',[0 0 0])

% blow up trace detail so it almost fills frame
maxAmpl = max(abs(data));
if (maxAmpl == 0) % make sure that max_ampl is not zero
	maxAmpl = 1;
end


%datetick('x', 15, 'keeplimits');
set(gca, 'XTick', Xtickmarks, 'XTickLabel', '', 'XLim', [timewindow.start timewindow.stop], 'Ytick',[],'YTickLabel',['']);
%axis tight;

if ~isnan(maxAmpl) % make sure it is not NaN else will crash
	traceRange = [dnum(1) dnum(end) -maxAmpl*1.1 maxAmpl*1.1];
	axis(traceRange);
end
