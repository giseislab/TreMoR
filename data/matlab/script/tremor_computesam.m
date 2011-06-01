function tremor_computesam(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_sam');

	% Output some information
	disp(sprintf('\n***** New waveform *****'));
	disp(sprintf('Start time is %s UTC',datestr(snum)));
	disp(sprintf('End time is %s UTC',datestr(enum)));

	% Calculate and save true ground motion data (at the
	% seismometer) to file (no reduced measurements)
  	onemin = waveform2onemin(w);
	onemin2bobfiles(onemin);

	% Remove waveforms MAT file
	delete(filename);

	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)








