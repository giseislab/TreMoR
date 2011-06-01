function onemin2bobfiles(onemin)
% onemin2bobfiles(onemin)
% Take a onemin structure and save it to bobfiles
% datasets contained in a onemin structure include
% Vmax, Vmedian, Dmax, Dmedian, Dstd, Energy, peakf and meanf
print_debug(sprintf('> %s', mfilename),1)

for c = 1:length(onemin)
    o = onemin(c);
	print_debug(sprintf('\nProcessing %s %s',o.station, o.channel),1);
    measurements = {'Vmax';'Vmedian';'Dmax';'Dmedian';'Energy';'peakf';'meanf';'Dmean';'Drms'};
	for m = 1:length(measurements)
	    measure = measurements{m};	 
		if isfield(o,measure)
                print_debug(sprintf('Calling save2bob for %s', measure),3);
        		save2bob(o.station, o.channel, o.dnum, getfield(o,measure),  measure);
        else
                print_debug(sprintf('measure %s not found',measure),3);
        end
    end
    % can also save to wfmeas tables with commands like:    
                %save2wfmeas(staname, channel, dnum, Vmax, 'Vmax','nm/s');
                %save2wfmeas(staname, channel, dnum, Dstd, 'Dstd', 'nm');       
                %save2wfmeas(staname, channel, dnum, peakf, 'peakf', 'Hz');     
end
print_debug(sprintf('< %s', mfilename),1)

