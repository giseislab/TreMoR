function tremor_computesam2(waveformsdir)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat(waveformsdir);

	% Calculate and save true ground motion data (at the
	% seismometer) to file (no reduced measurements)
	try
    		stats = waveform2stats(w, 1/60);  
    		%stats = waveform2f(w);
	catch	
		disp('waveform2stats failed');
    		%delete(filename);
	end

    	for c = 1:length(stats)
    		samcollection = stats(c);
     	 	%measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
       		measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
        	for m = 1:length(measurements)
            		measure = measurements{m};	 
            		if isfield(samcollection, measure)
                		eval(sprintf('s = samcollection.%s;',measure));
   		        	if isempty(s)
            	        		print_debug(sprintf('SAM object for %s is blank',measure),2);
       			    	else
                    			print_debug(sprintf('Calling save2bob for %s', measure),3);
                    			try
                       				save2bob(s.station, s.channel, s.dnum, s.data, measure);
		               		catch
						disp(sprintf('save2bob failed for %s-%s',s.station, s.channel));
                	  		end
		        	end
       		 	else
      				print_debug(sprintf('measure %s not found',measure),2);
       	    		end
       		end
    	end

	% Remove waveforms MAT file
        if ~isempty(filename)
        	if exist(filename,'file')
                        delete(filename);
                end
        end

	% Pause briefly
	pause(5);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)








