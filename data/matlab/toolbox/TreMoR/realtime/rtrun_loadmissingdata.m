startup_tremor;
libgt.set_debug(12);
while 1
	logbenchmark('loadwaveformdata', 0);
	tremor_loadwaveformdata('snum', utnow-60/1440, 'delaymins', 11);
	pause(10);
end
