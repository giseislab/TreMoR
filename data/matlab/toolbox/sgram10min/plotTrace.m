function plotTrace(tracePosition, data, freqSamp, Xtickmarks, timewindow);
snum =timewindow.start;

% set axes position
axes('position',tracePosition);

% trace time vector - bins are ~0.01 s apart (not 5 s as for spectrogram time)
% not really worthwhile plotting more than 1000 points on the screen
dnum = ((1:length(data))./freqSamp)/86400 + snum;

% plot seismogram
try
	data = detrend(data);
end
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
