function [w,filtered]=waveform_clean(w, varargin)
% [w,filtered] = waveform_clean(w)
print_debug(sprintf('> %s',mfilename),2);
warning on;

[remove_calibs, remove_spikes, remove_trend, remove_response, interactive_mode, filterObj] = ...
    process_options(varargin, 'remove_calibs', false, 'remove_spikes', false, 'remove_trend', false, 'remove_response', false, ...
    'interactive_mode', false, 'filterObj', filterobject('b',[0.5 15],2) );

if remove_calibs
    try
        w=waveform_removeCalibrationPulses(w);
    catch
        disp('waveform_removeCalibrationPulses failed');
    end
end

for c = 1: length(w)
    if remove_spikes
        if interactive_mode
            figure;
            plot(w(c));
            title('raw');
            anykey();
        
            %w(c)=waveform_spike(w(c));
            figure;
            plot(w(c));
            title('spiked');
            anykey();        
        end
    
        % despike & declip
        m = median(abs(w(c)));
        while std(w(c)) > 100*m
            w(c) = clip(w(c),100*m);
            w(c) = waveform_despike(w(c));
            m = median(abs(w(c)));
        end
        if interactive_mode
            figure;
            plot(w(c));
            title('despiked');
            anykey();
        end  
    end
    
    if remove_trend
        w(c) = detrend(fillgaps(w(c),mean(w(c))));
        if interactive_mode
            figure;
            plot(w(c));
            title('detrended');
            anykey();
        end   
    end

    % high pass filter (and remove response if requested)
    filtered = false;
    if remove_response == true
            try
                resp = get(w(c), 'response') % I think the getwaveforms2, which gets from antelope, appends response using addfield to waveform object
                if ~isempty(resp)
			if nanmean(resp.values) ~= 0 % if i look at subnets(15).stations(6).response, which is SSLN-BDF, it has a response, but all values are zero, so i would want to skip it
                    		w(c) = response_apply(w(c), filterObj, 'structure', resp);
				% Note: Assumes responses are preloaded into runtime.mat, subnets variable. To get responses directly from Antelope, use:
                		% w(c) = response_apply(w(c),filterObj,'antelope','dbmaster/master_stations');
                		filtered = true; % set this, so we don't apply butterworth filter again below
			end
                end
            catch
                warning(sprintf('response_apply failed .\nTrying to bandpass instead.'));
            end
    else
	% apply calib
	try
		if strcmp(get(w(c),'Units'), 'Counts')
			resp = get(w(c), 'response');
			print_debug(sprintf('Applying calib of %d for %s.%s',resp.calib, get(w(c),'station'), get(w(c), 'channel')), 1);
			if (resp.calib ~= 0)
				w(c) = w(c) * resp.calib;
				w(c) = set(w(c), 'units', resp.units);
			end
		end
	catch
		print_debug('Failed to apply calib', 1);
	end
	
    end

    if ~filtered
            try
                w(c) = waveform_bandpass(w(c),filterObj); 
                filtered = true; 
            end
    end       
    if ~filtered
        print_debug('Cannot filter waveform',0);
    end
    
end

print_debug(sprintf('< %s',mfilename),2);
