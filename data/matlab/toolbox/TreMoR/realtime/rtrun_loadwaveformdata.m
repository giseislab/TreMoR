startup_tremor;
libgt.set_debug(12);
while 1
	logbenchmark('loadwaveformdata', 0);
	tremor_loadwaveformdata('delaymins',1);
	pause(10);
end
