startup_tremor;
debug.set_debug(12);
while 1
	logbenchmark('loadwaveformdata', 0);
	tremor_loadwaveformdata('snum', utnow-1/24, 'delaymins', 11);
	pause(10);
end
