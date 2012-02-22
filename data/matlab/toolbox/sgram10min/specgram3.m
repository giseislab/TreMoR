function result=specgram3(w, titlestr, s, spectrogramFraction)
% specgram3(w [,titlestr [,s] ])
% Wrapper for spectralobject/specgram that produces an IceWeb-like spectrogram
%
% Example:
%    specgram3(waveformWrapper2(subnet, timewindow), '', PARAMS.spectralobject)
%
% waveform should already have had zero-length waveform objects replaced by zero vectors 

print_debug(sprintf('> %s',mfilename),2)
result = 0;

numw = length(w);
if numw==0
	return;
end
if ~exist('s','var')
	s = spectralobject(1024, 924, 10, [60 120]);
end
if ~exist('spectrogramFraction','var')
	spectrogramFraction = 1;
end

print_debug(sprintf('%d waveform objects',numel(w)),0);

% draw spectrogram using Celso's 
try
	sg = specgram(s, w, 'xunit', 'date', 'colorbar', 'none', 'yscale', 'normal', 'colormap', 'jet'); % default for colormap is SPECTRAL_MAP

catch
	save specgram-fillempty-failed.mat w
	print_debug('specgram failed on waveform vector. Trying again, using nonempty rather than fillempty',0);
	w = waveform_nonempty(w);
	if numel(w)>0
		print_debug(sprintf('%d waveform objects after removing empty waveform objects',numel(w)),0);
		try
			sg = specgram(s, w, 'xunit', 'date', 'colorbar', 'none', 'yscale', 'normal', 'colormap', 'jet'); % default for colormap is SPECTRAL_MAP
		catch
			save specgram-nonempty-failed.mat w
			disp('specgram3 crashed again');
		end	
	else
		print_debug('specgram failed on waveform vector. Tried nonempty rather than fillempty, but looks like all waveform objects were empty, so skipping',0);
		return;
	end	
end

% Get axis handles
ha = get(gcf, 'Children');

% Change X-Labels
hxl = get(ha, 'XLabel');
if numw > 1
	for c=1:numw
		set(hxl{c}, 'String', '');
	end
else
%	set(hxl, 'String', '');
end

% Change Y-Labels to 'sta\nchan'
station = fliplr(waveform2station(w));
for c=1:numw
	hyl = get(ha(c), 'YLabel');
	hyl_string = sprintf('%s\n%s',station(c).name, station(c).channel);
	set(hyl, 'String', hyl_string,'FontSize',12);
end

% Remove titles
for c=1:numw
	ht = get(ha(c), 'Title');
	set(ht, 'String', '');
end
if exist('titlestr','var')
	set(ht,'String',titlestr,'Color',[0 0 0],'FontSize',[14], 'FontWeight',['bold']');
end

% Set appropriate date ticks
[wsnum, wenum]=gettimerange(w);
wt.start = min(wsnum);
wt.stop = max(wenum);
[Xtickmarks,XTickLabel]=findMinuteMarks(wt);
set(ha, 'XTick', Xtickmarks, 'XTickLabel', {},  'FontSize', 10);
set(ha(1), 'XTick', Xtickmarks, 'XTickLabel', XTickLabel, 'FontSize', 10);

% Set X-range to full time range
set(ha,'XLim', [wt.start wt.stop]);

% Reset axes position & squeeze in the trace panels
for c=1:numw
	[spectrogramPosition, tracePosition] = calculateFramePositions(length(w), c, spectrogramFraction, 0.8, 0.8);
	set(ha(c), 'position', spectrogramPosition);
	if spectrogramFraction < 1
		plotTrace(tracePosition, get(w(numw-c+1),'data'), get(w(numw-c+1),'freq'), Xtickmarks, wt);
		set(gca,'XLim', [wt.start wt.stop]); % added 20111214 to align trace with spectrogram when data missing (prevent trace being stretched out)
		thischan = get(w(c), 'channel');
		if (regexp(thischan, 'BH.'))
			set(gca, 'Color', [1 .5 .5]);
		end
	end
end
result = 1;
print_debug(sprintf('< %s',mfilename),2);



