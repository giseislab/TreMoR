function w=getwaveforms(scnl, snum, enum, ds);
% GETWAVEFORMS returns a waveform object (or vector of waveform objects)
% corresponding to the scnlobject and datenums passed as parameters. 
% W = getWaveforms(SCNLOBJECT, SNUM, ENUM, DS)
% For help on building a SCNLOBJECT structure type 'help scnlobject'.
% For help on the WAVEFORM class, type 'help waveform'.
%
%	w = getwaveforms(scnl, snum, enum, fraction);
%
% Glenn Thompson, 2008
%

global paths PARAMS;
tic;
t=toc;
if isstruct(snum)
	error('getwaveforms now uses snum & enum. timewindow is discontinued');
end

warning off;
print_debug(sprintf('> %s', mfilename),1)

% get datasource
if isempty(ds)
    print_debug('No valid datasource',1);
	w=[];	
    return;
end


numchannels = length(get(scnl, 'station')); % assumes station channel pairs
scnlgot = zeros(1:numchannels);
for c=1:numchannels
	w(c) = waveform;
end

% loop over all data sources until some data found
for dsi=1:length(ds)
	for c=1:numchannels	
		if scnlgot(c)==0
			fname = getfilename(ds(dsi),scnl(c), snum);
			print_debug(sprintf('Attempting to load waveform data for %s-%s from %s from %s',get(scnl(c),'station'),get(scnl(c),'channel'),datestr(snum,31),fname{1}),0);
			try	
               			w(c) = waveform(ds(dsi), scnl(c), snum, enum); % CALL WAVEFORM
				if get(w(c), 'data_length') > 0
					addfield(w(c), 'ds', fname{1});
					scnlgot(c)=1;
				end
			catch
               			w(c) = waveform;
			end
		end	
	end	
end

% now remove any waveforms which are empty
w = w(find(scnlgot==1));
print_debug(sprintf('- got %d waveform objects, took %.1f s\n', length(w), toc-t),1);

print_debug(sprintf('< %s', mfilename),1)


