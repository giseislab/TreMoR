function w=loadwaveform(station, channel, waveservername, snum, enum)
scnl = scnlobject(station, channel, 'AV')
if strcmp(waveservername, 'churchill')
	ds = datasource('winston', 'churchill.giseis.alaska.edu', 16022);
end
if strcmp(waveservername, 'pubavo1')
	ds = datasource('winston', 'pubavo1.wr.usgs.gov', 16022);
end
w = waveform(ds, scnl, snum, enum); 
%w = getwinstonwaveforms(scnl, snum, enum, ds);
