function w=getwaveforms(scnl, snum, enum);
% GETWAVEFORMS returns a waveform object (or vector of waveform objects)
% corresponding to the scnlobject and datenums passed as parameters. 
% W = getWaveforms(SCNLOBJECT, SNUM, ENUM)
% For help on building a SCNLOBJECT structure type 'help scnlobject'.
% For help on the WAVEFORM class, type 'help waveform'.
%
%	w = getwaveforms(scnl, snum, enum);
%
% Glenn Thompson, 2008
%
% This function includes a special debug level of 10 which launches an
% interactive plotting mode.

global paths PARAMS;
tic;
t=toc;
if isstruct(snum)
	error('getwaveforms now uses snum & enum. timewindow is discontinued');
end

%PARAMS.response = 1;
if (get_debug()==10)
    interactivemode = 1;
else
    interactivemode = 0;
end
warning off;
print_debug(sprintf('> %s', mfilename),1)

w = [];

% get datasource
ds = get_datasource(snum, enum);
if isempty(ds)
    print_debug('No valid datasource',1);
    return;
end

% loop over all data sources until some data found
dsi = 1;
while (length(w)==0 && dsi<=length(ds)),  
%	try
		if (floor(snum) < floor(enum) )
			dnum = snum;
			c = 0;
			w0 = [];
			while (dnum < enum), % loop over many days
				enum0 = min([enum floor(dnum+1)]);
				print_debug(ds(dsi),3);
				%print_debug(sprintf('Trying to load waveform data from %s to %s from %s ',datestr(dnum,0), datestr(enum,0), get(dsi, 'location')));
				c = c + 1;
				try
					wtemp = waveform(ds(dsi), scnl, dnum, enum0 ); % CALL WAVEFORM
					w0 = [w0 wtemp];
					clear wtemp;
				end
				dnum = floor(dnum + 1);
			end
			w = combine(w0);
			clear w0
        else % within a single day
			print_debug(ds(dsi),3);
			%print_debug(sprintf('Trying to load waveform data from %s to %s from %s ',datestr(snum,0), datestr(enum,0), get(dsi, 'location')));
			%print_debug(sprintf('Loading data from %s to %s from datasource %d of %d ',datestr(snum,0),datestr(enum,0), dsi, length(ds)),2);

            try
                w = waveform(ds(dsi), scnl, snum, enum); % CALL WAVEFORM
            catch
                w=[];
            end
		end
%	end

	print_debug(sprintf('- got %d waveform objects, took %.1f s\n', length(w), toc-t),1);
	dsi = dsi + 1;
end

print_debug(sprintf('< %s', mfilename),1)


