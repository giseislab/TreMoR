startup_tremor;
libgt.set_debug(12);
while 1
	logbenchmark('loadwaveformdata', 0);
	tremor_loadlivedata('delaymins',1);
	pause(10);
end
