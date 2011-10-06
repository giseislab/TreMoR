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

numchannels = numel(scnl); % assumes station channel pairs
scnlgot = zeros(numchannels,1);
for c=1:numchannels
	w(c) = waveform;
end


%% loop over all data sources until some data found
scnlsta = get(scnl, 'station');
scnlchan = get(scnl, 'channel');

% all station mode for speed
disp('ALL STATIONS MODE');
finished = false;
for dsi=1:length(ds)
	scnltoget = scnl(scnlgot==0);
	if (length(scnltoget)==0)
		disp('Got data for all scnls');
		finished = true;
		break;
	end
	
	disp(sprintf('Trying datasource %d of %d',dsi,length(ds)));
	fname = getfilename(ds(dsi),scnl(c), snum);
	if exist(fname{1}, 'file')
		print_debug(sprintf('Attempting to load waveform data for %d remaining stations (of %d total) at %s from %s',length(scnltoget),numchannels,datestr(snum,31),fname{1}),0);
		try	
        	 	w_new = waveform(ds(dsi), scnltoget, snum, enum); 
		catch ME
			disp('%%% Caught exception:%%%');
			disp(ME.message);
			disp('%%% End of exception:%%%');
			mydatasource = ds(dsi);
			errorfile = datestr(now,30);
			eval(['save ',errorfile,' mydatasource scnltoget snum enum ME']);
			w_new = [];
		end
		if ~isempty(w_new)
			for c=1:numchannels
				for cw = 1:numel(w_new)
					sta = get(w_new(cw), 'station');
					chan = get(w_new(cw), 'channel');
					if (strcmp(sta, scnlsta{c}) & strcmp(chan, scnlchan{c}))
						% w_new(cw) corresponds to scnl(c)
						if get(w_new(cw), 'data_length') > 0
							w(c) = addfield(w_new(cw), 'ds', fname{1});
							w(c) = addfield(w(c), 'mode', 'all');
							scnlgot(c)=1;
						end
					end
				end
			end
		end
	else
		fprintf('the database %s does not exist: skipping call to waveform\n',fname{1});
	end
end	

% individual station mode to fill in blanks
if ~finished 
	disp('SINGLE CHANNEL MODE');
	for dsi=1:length(ds)
		scnltoget = scnl(scnlgot==0);
		if (length(scnltoget)==0)
			disp('Got data for all scnls');
			finished = true;
			break;
		end
		
		for c=1:numchannels	
			if scnlgot(c)==0
				fname = getfilename(ds(dsi),scnl(c), snum);
				print_debug(sprintf('Attempting to load waveform data for %s-%s at %s from %s',get(scnl(c),'station'),get(scnl(c),'channel'),datestr(snum,31),fname{1}),0);
				try	
	               			w(c) = waveform(ds(dsi), scnl(c), snum, enum) % CALL WAVEFORM
				catch ME
					disp('%%% Caught exception:%%%');
					disp(ME.message);	
					disp('%%% End of exception:%%%');
					mydatasource = ds(dsi);
					errorfile = datestr(now,30);
					eval(['save ',errorfile,' mydatasource scnltoget snum enum ME']);
				end
				if get(w(c), 'data_length') > 0
					w(c) = addfield(w(c), 'ds', fname{1});
					w(c) = addfield(w(c), 'mode', 'single');
					scnlgot(c)=1;
				end
			end	
		end
	end
end	
% now remove any waveforms which are empty
w = w(find(scnlgot==1));
for i=1:numel(w)
	sta0 = get(w(i), 'station');
	chan0 = get(w(i), 'channel');
	ds0 = get(w(i), 'ds');
	mode0 = get(w(i), 'mode');
	dl0 = get(w(i), 'data_length');
	fprintf('waveform %d: got %d samples for %s-%s from %s in mode %s\n',i,dl0,sta0,chan0,ds0,mode0);
end
print_debug(sprintf('- got %d waveform objects, took %.1f s\n', length(w), toc-t),1);

print_debug(sprintf('< %s', mfilename),1)
fprintf('\n\n\n\n');
pause(10);

