function rtrun_loadmissingdata(matfile)
startup_tremor;
if ~exist('matfile', 'var')
    matfile = getenv('MATFILE');
end
debug.set_debug(12);
while 1
	logbenchmark('loadwaveformdata', 0);
	tremor_loadwaveformdata('snum', utnow-1/24, 'delaymins', 11, 'matfile', matfile);
	pause(10);
end
