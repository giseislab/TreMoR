function rtrun_loadwaveforms(varargin)
startup_tremor;
[snum, delaymins, matfile] = matlab_extensions.process_options(varargin, 'snum', 0, 'delaymins', 0, 'matfile', getenv('MATFILE'));
debug.set_debug(3);
while 1
	logbenchmark(mfilename, 0);
	if (snum>0)
		tremor_loadwaveformdata('snum', snum, 'delaymins', delaymins, 'matfile', matfile);
	else
		tremor_loadwaveformdata('delaymins', delaymins, 'matfile', matfile);
	end
	pause(60);
end
