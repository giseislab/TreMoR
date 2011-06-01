function w=waveform_removeCalibrationPulses(w)
print_debug(sprintf('> %s',mfilename),2);
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

print_debug(sprintf('< %s',mfilename),2);

