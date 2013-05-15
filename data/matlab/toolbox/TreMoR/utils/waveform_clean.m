function [w,filtered]=waveform_clean(w, varargin)
% WAVEFORM_CLEAN Clean up a vector of waveform objects
% w = waveform_clean(w, varargin);
% varargin named variables are:
%	'remove_calibs' [false]
%	'remove_trend' [false]
%	'remove_response' [false]
%	'interactive_mode' [false]
%	'filter_waveforms' [true]
%	'filterObj' [ filterobject('b', [0.5 15], 2) ]

% AUTHOR: Glenn Thompson, UAF-GI
% $Date: $
% $Revision: -1 $
% [w,filtered] = waveform_clean(w)
print_debug(sprintf('> %s',mfilename),2);
warning on;

[remove_calibs, remove_spikes, remove_trend, remove_response, interactive_mode, filter_waveforms, filterObj] = ...
    process_options(varargin, 'remove_calibs', false, 'remove_spikes', false, 'remove_trend', false, 'remove_response', false, ...
    'interactive_mode', false, 'filter_waveforms', true, 'filterObj', filterobject('b',[0.5 15],2) );

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
            w(c) = despike(w(c));
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
                resp = get(w(c), 'response'); 
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
			debug.print_debug(sprintf('Applying calib of %d for %s.%s',resp.calib, get(w(c),'station'), get(w(c), 'channel')), 1);
			if (resp.calib ~= 0)
				w(c) = w(c) * resp.calib;
				w(c) = set(w(c), 'units', resp.units);
			end
		end
	catch
		debug.print_debug('Failed to apply calib', 1);
	end
	
    end
    if filter_waveforms == true

   	 if ~filtered
   	         try
   	             w(c) = bandpass(w(c),filterObj,'pad',true); 
   	             filtered = true; 
		 catch
			debug.print_debug('Failed waveform_bandpass', 1);
   	         end
   	 end       
   	 if ~filtered
   	     debug.print_debug('Cannot filter waveform',0);
   	 end
   end
    
end

debug.print_debug(sprintf('< %s',mfilename),2);


function anykey()
dummy = input('Press any key to continue');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=waveform_removeCalibrationPulses(w)
debug.print_debug(sprintf('> %s',mfilename),2);
lengthOfCalibPulse = 60; % seconds
w=waveform_addsgram(w);
for c=1:length(w)
% Remove calib pulses
    sgram = get(w(c), 'sgram');
    if ~isempty(sgram)
        snum = get(w(c),'start');
        data = get(w(c),'data');
        Fs=get(w(c),'freq');
        S = sgram.S;
        F = sgram.F;
        T = sgram.T;
        i = find(F>21.0 & F<21.6);
        j = find(F>19.0 & F<20.0);
        for cc=1:length(T)
            Cchannel(cc) = mean(S(i,cc));
            Nchannel(cc) = mean(S(j,cc));
        end
        lr = length(data)/length(T);
        %k = find(Cchannel > 3 * Nchannel & Cchannel > 1e5);
        k = find(Cchannel > 5 * Nchannel & Cchannel > 5e5);
        calibsamples = contiguous(k);
        calibtimes.start = T(calibsamples.start)/86400 + snum;
        calibtimes.end = (T(calibsamples.end) + lengthOfCalibPulse)/86400 + snum;
        w(c)=addfield(w(c), 'calibtimes', calibtimes);
    
        if length(k) > 0
            dstart = round(lr*k(1));
            dend = round(lr*k(end)) + (Fs * lengthOfCalibPulse);
            data( dstart : dend  )=NaN;
            w(c)=set(w(c),'data',data);
        end
    end
end

debug.print_debug(sprintf('< %s',mfilename),2);


