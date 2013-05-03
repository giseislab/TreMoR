function rtrun_tremorwrapper(queue_num, matfile)
set(0, 'DefaultFigureVisible', 'off');
if ~exist('matfile', 'var')
    matfile = getenv('MATFILE');
end
debug.set_debug(12);
while 1
	logbenchmark('rtrun_tremorwrapper', 0);
	tremor_wrapper(sprintf('waveform_files/queue%d',queue_num), matfile);
	disp('************** PROBABLE CRASH ***********');
	pause(60);
end
