function tremor_computesam2(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_sam');

	% Output some information
	disp(sprintf('\n***** New waveform *****'));
	disp(sprintf('Start time is %s UTC',datestr(snum)));
	disp(sprintf('End time is %s UTC',datestr(enum)));

	% Calculate and save true ground motion data (at the
	% seismometer) to file (no reduced measurements)
  	onemin = waveform2onemin(w);
    stats = waveform2stats(w, 1/60);
    %stats = waveform2f(w);
	%onemin2bobfiles(onemin);

    for c = 1:length(stats)
        s = stats(c);
        %measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
        measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
        for m = 1:length(measurements)
            measure = measurements{m};	 
            if isfield(s, measure)
                f = get(s, measure);
                print_debug(sprintf('Calling save2bob for %s', measure),3);
        		save2bob(f.station, f.channel, f.dnum, f.data,  measure);
            else
                print_debug(sprintf('measure %s not found',measure),3);
            end
        end
    end

	% Remove waveforms MAT file
	delete(filename);

	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)








