startup_tremor;
debug.set_debug(12);
while 1
	logbenchmark('rtrun_dealwaveformfiles', 0);
	dealwaveformfiles('waveform_files/loaded','waveform_files/queue');
	disp('************** PROBABLE CRASH ***********');
	pause(60);
end
