function rtrun_loadwaveformdata(matfile)
if ~exist('matfile', 'var')
    matfile = getenv('MATFILE');
end
startup_tremor;
debug.set_debug(12);
while 1
	logbenchmark('loadwaveformdata', 0);
	tremor_loadwaveformdata('delaymins',1,'matfile',matfile);
	pause(10);
end
