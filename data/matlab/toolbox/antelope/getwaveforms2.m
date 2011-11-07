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

%warning off;
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
	
	print_debug(sprintf('- Trying datasource %d of %d',dsi,length(ds)),1);
	fname = getfilename(ds(dsi),scnl(c), snum);
	if exist(fname{1}, 'file')
		%try	
			print_debug(sprintf('- Checking if miniseed files exist for %d remaining stations (of %d total) at %s from %s',length(scnltoget),numscnls,datestr(snum,31),fname{1}),1);
			scnltoget = miniseedExists(ds(dsi), scnltoget, snum, enum);
			if length(scnltoget)>0
				print_debug(sprintf('- Attempting to load waveform data for %d remaining stations (of %d total) at %s from %s',length(scnltoget),numscnls,datestr(snum,31),fname{1}),1);
        	 		w_new = waveform(ds(dsi), scnltoget, snum, enum); 
			else
				print_debug('No miniseed files to get',1);
				continue;
			end
		%catch ME
		%	print_debug('Bugger! Either miniseedExists or waveform filed',1); 
		%	handle_waveform_crash(ME, ds(dsi), scnltoget, snum, enum);
		%	w_new = [];
		%end
		if ~isempty(w_new)
			[w, scnlgot] = deal_waveforms(w, w_new, scnlgot, fname{1});
		end
	else
		print_debug(sprintf('the database %s does not exist: skipping call to waveform\n',fname{1}),2);
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
		
		for c=1:numscnls	
			if scnlgot(c)==0
				fname = getfilename(ds(dsi),scnl(c), snum);
				print_debug(sprintf('- Checking if miniseed files exist for %d remaining stations (of %d total) at %s from %s',length(scnltoget),numscnls,datestr(snum,31),fname{1}),1);
				%try	
					scnltoget = miniseedExists(ds(dsi), scnl(c), snum, enum);
					if length(scnltoget)>0
						print_debug(sprintf('- Attempting to load waveform data for %s-%s at %s from %s',get(scnl(c),'station'),get(scnl(c),'channel'),datestr(snum,31),fname{1}),0);
        	 				w_new = waveform(ds(dsi), scnltoget, snum, enum); 
					else
						print_debug('No miniseed files to get',1);
						continue;
					end
				%catch ME
				%	print_debug('Bugger! Either miniseedExists or waveform filed',1); 
				%	handle_waveform_crash(ME, ds(dsi), scnl(c), snum, enum);
				%	w_new = [];
				%end
				if ~isempty(w_new)
					[w, scnlgot] = deal_waveforms(w, w_new, scnlgot, fname{1});
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
print_debug(sprintf('- Got %d waveform objects, took %.1f s\n', length(w), toc-t),1);
print_debug(sprintf('< %s', mfilename),1)
fprintf('\n\n\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w,scnlgot] = deal_waveforms(w, w_new, scnlgot, dbname)
% take arrays of waveforms we just got, and waveforms we already have 
for i=1:numel(w)
	sta = get(w(i), 'station');
	chan = get(w(i), 'channel');
	for j = 1:numel(w_new)
		sta_new = get(w_new(j), 'station');
		chan_new = get(w_new(j), 'channel');
		if (strcmp(sta_new, sta) & strcmp(chan_new, chan))
			% w_new(j) corresponds to scnl(i)
			if get(w_new(j), 'data_length') > 0
				w(i) = addfield(w_new(j), 'ds', dbname);
				w(i) = addfield(w(i), 'mode', 'all');
				scnlgot(i)=1;
			end
		end
	end
end

function [w,scnlgot] = deal_waveforms2(w, w_new, scnlgot, dbname)
% take arrays of waveforms we just got, and waveforms we already have 
stations = get(w, 'station');
channels = get(w, 'channel');
for j=1:numel(w_new)
	sta_new = get(w_new(j), 'station');
	chan_new = get(w_new(j), 'channel');
	i = strfind(stations, sta_new);
	if length(i)>0
		for c=1:length(i)
			if strcmp(channels{i(c)}, chan_new)
				k = i(c);
				% sta_new and chan_new matched
				if isempty(w(k))
					w(i) = addfield(w_new(j), 'ds', dbname);
				else
					w(i) = combine(w(i), w_new(j));
					w(i) = addfield(w(i), 'ds', dbname);
				end
				w(i) = addfield(w(i), 'mode', 'all');
				scnlgot(i)=1;
			end
		end
	end
end


function handle_waveform_crash(ME, mydatasource, scnltoget, snum, enum)
print_debug(sprintf('// Caught exception\n%s\n   End exception\n',ME.message),2);
errorfile = sprintf('error_%s',datestr(now,30));
eval(['save ',errorfile,' mydatasource scnltoget snum enum ME']);
eout = fopen('loaderrors.txt', 'a');
sta = get(scnltoget,'station');
chan = get(scnltoget, 'chan');
filename = getfilename(mydatasource, scnltoget, snum);
sds = datestr(snum);
eds = datestr(enum);
fprintf('%s.%s\t%s\t%s\t%s\t%s\n',sta,chan,sds,eds,filename,ME.message);
fclose(fout);
