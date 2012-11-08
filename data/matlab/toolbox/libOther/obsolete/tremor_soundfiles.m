function tremor_soundfiles(waveformdir)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime
while 1,

	tic;
	[w, filename, snum, enum, subnet] = loadnextwaveformmat(waveformdir);

	tenminspfile = getSgram10minName(subnet, enum);
	[bname, dname, bnameroot, bnameext] = basename(tenminspfile);
	for c=1:length(w)
		soundfilename = catpath(dname, sprintf('%s_%s_%s.wav',bnameroot, get(w(c),'station'), get(w(c), 'channel')  ) );
		print_debug(sprintf('Writing to %s',soundfilename),0); 
		%waveform2sound(w(c), soundfilename); % function is useless - hardwired to /home/celso!
		data = get(w(c),'data');
		m = max(data);
		if m == 0
			m = 1;
		end 
		data = data / m;
		wavwrite(data, get(w(c), 'freq') * 120, soundfilename);
	end
	logbenchmark(mfilename, toc);
	
	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
