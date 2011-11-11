function tremor_filterwaveformdata(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_raw');

        if isempty(w)
                fprintf('.');
        else

                % Sanity checks
                errorFound=false;
                if ~strcmp(class(w),'waveform')
                        errorFound=true;
                end
                if ~(snum>datenum(1989,1,1) && snum<utnow)
                        errorFound=true;
                end
                if ~(enum>datenum(1989,1,1) && enum<utnow)
                        errorFound=true;
                end
                if length(subnet)==0
                        errorFound=true;
                end

                if ~errorFound
                        % Output some information
                        disp(sprintf('\n***** New waveform *****'));
                        fprintf('file=%s\n',filename);
                        disp(sprintf('Start time is %s UTC',datestr(snum)));
                        disp(sprintf('End time is %s UTC',datestr(enum)));
        
       	 		% Add response structures to waveform objects
        
        		% Remove calibs, despike, detrend and deconvolve waveform data
        		w = waveform_clean(w, 'filterObj', PARAMS.filterObj);

			% Save waveforms
			save2waveformmat(w, 'waveforms_filtered', snum, enum, subnet);

		end

                if ~isempty(filename)
                        if exist(filename,'file')
                                system(sprintf('mv -f %s done/',filename));
                                %delete(filename);
                        end
                end
        end

        % Pause briefly
        pause(5);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

