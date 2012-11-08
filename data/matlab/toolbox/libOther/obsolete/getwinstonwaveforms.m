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

print_debug(sprintf('> %s', mfilename),1)

% get datasource
if isempty(ds)
    print_debug('No valid datasource. Exiting.',1);
	w=[];	
    return;
end

numscnls = numel(scnl); % assumes station channel pairs

% scnlgot will record which scnls we've got data for, and which we haven't
% initially set scnlgot for each scnl to 0.
scnlgot = zeros(numscnls,1);

% start off with blank waveform objects
for c=1:numscnls
	w(c) = waveform;
	w(c) = set(w(c), 'station', get(scnl(c), 'station') );
	w(c) = set(w(c), 'channel', get(scnl(c), 'channel') );
end


%% loop over all data sources until some data found
% - all station mode for speed
print_debug('- ALL STATIONS MODE',2);
finished = false;
for dsi=1:length(ds)
	scnltoget = scnl(scnlgot==0);
	if (length(scnltoget)==0)
		print_debug('- Got data for all scnls',2);
		finished = true;
		break;
	end
	servername = get(ds(dsi),'server');	
%	try	
		if length(scnltoget)>0
			print_debug(sprintf('- Attempting to load waveform data for %d remaining stations (of %d total) at %s from %s',length(scnltoget),numscnls,datestr(snum,31),servername),0);
			print_waveform_call(snum, enum, scnltoget, ds(dsi))
                       	w_new = waveform(ds(dsi), scnltoget, snum, enum); 
		else
			continue;
		end
%	catch ME
%		print_debug('waveform failed',1); 
%		w_new = [];
%	end
	if ~isempty(w_new)
		[w, scnlgot] = deal_waveforms(w, w_new, scnlgot, servername);
	end
end	

% - individual station mode to fill in blanks
if ~finished 
	print_debug('- SINGLE CHANNEL MODE',2);
	for dsi=1:length(ds)
		scnltoget = scnl(scnlgot==0);
		if (length(scnltoget)==0)
			print_debug('- Got data for all scnls',2);
			finished = true;
			break;
		end
		
		servername = get(ds(dsi),'server');	
		for c=1:numscnls	
			if scnlgot(c)==0
				try	
					if length(scnltoget)>0
						print_debug(sprintf('- Attempting to load waveform data for %s-%s at %s from %s',get(scnl(c),'station'),get(scnl(c),'channel'),datestr(snum,31),servername),0);
						print_waveform_call(snum, enum, scnltoget, ds(dsi))
        	 				w_new = waveform(ds(dsi), scnltoget, snum, enum); 
					else
						continue;
					end
				catch ME
					print_debug('waveform failed',1); 
					w_new = [];
				end
				if ~isempty(w_new)
					[w, scnlgot] = deal_waveforms(w, w_new, scnlgot, get(ds(dsi), 'server') );
				end
			end	
		end
	end
end	
% now remove any waveforms which are empty
%w = w(find(scnlgot==1));

% report what waveforms we got and where they came from 
for i=1:numel(w)
	sta0 = get(w(i), 'station');
	chan0 = get(w(i), 'channel');
	ds0 = get(w(i), 'ds');
	mode0 = get(w(i), 'mode');
	dl0 = get(w(i), 'data_length');
	print_debug(sprintf('- waveform %d: got %d samples for %s-%s from %s in mode %s',i,dl0,sta0,chan0,ds0,mode0),2);
end
print_debug(sprintf('- Got %d waveform objects\n', length(w)),1);
print_debug(sprintf('< %s', mfilename),1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w,scnlgot] = deal_waveforms(w, w_new, scnlgot, servername)
% take arrays of waveforms we just got, and waveforms we already have 
for i=1:numel(w)
	sta = get(w(i), 'station');
	chan = get(w(i), 'channel');
	for j = 1:numel(w_new)
		sta_new = get(w_new(j), 'station');
		chan_new = get(w_new(j), 'channel');
		nsamp = length(get(w_new(j), 'data'));
		freq = get(w_new(j), 'freq');
		nsamp_expected = freq * 600;
		if (strcmp(sta_new, sta) & strcmp(chan_new, chan))
			% w_new(j) corresponds to scnl(i)
			nsamp_before = length(get(w(i), 'data'));
			if (nsamp > nsamp_before) 
				w(i) = addfield(w_new(j), 'ds', servername);
				w(i) = addfield(w(i), 'mode', 'all');
				if (nsamp == nsamp_expected)
					scnlgot(i)=1;
				end
			end
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_waveform_call(snum, enum, scnl, ds)
disp('Waveform call:')
fprintf('\tsnum = %f (%s)\n',snum,datestr(snum));
fprintf('\tenum = %f (%s)\n',enum,datestr(enum));
for c=1:length(scnl)
	fprintf('\tscnl(%d) = scnlobject('''%s''', '''%s''', '''%s''', '''%s''');\n',c, get(scnl(c), 'station'), get(scnl(c), 'channel'), get(scnl(c), 'network'), get(scnl(c), 'location'));
end
fprintf('\tds = datasource('''%s''', '''%s''', %d);\n', get(ds, 'type'), get(ds, 'server'), get(ds, 'port'));
fprintf('\tw = waveform(ds, scnl, %f, %f)\n', snum, enum);
