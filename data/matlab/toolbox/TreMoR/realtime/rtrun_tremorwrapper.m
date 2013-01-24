function startup_tremor(queue_num);
debug.set_debug(12);
while 1
	logbenchmark('rtrun_tremorwrapper', 0);
	tremor_wrapper(sprintf('waveform_files/queue%d',queue_num));
	disp('************** PROBABLE CRASH ***********');
	pause(60);
end
