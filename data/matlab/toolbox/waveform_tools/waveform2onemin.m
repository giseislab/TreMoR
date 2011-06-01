function onemin=waveform2onemin(w, varargin)
% onemin = waveform2onemin(w);

w=waveform_addsgram(w);
print_debug(sprintf('> %s',mfilename),2);
[interactive_mode] = process_options(varargin, 'interactive_mode', false);

for c=1:length(w)
    velocityWaveform = w(c);
    sgram = get(w(c), 'sgram');
    if isstruct(sgram)
        % downsample sgram data to 1 minute bins
        [Smax,i] = max(sgram.S);
        peakf = sgram.F(i);
        meanf = (sgram.F' * sgram.S)./sum(sgram.S);
        dnum = unique(floorminute(sgram.T/86400));
        for k=1:length(dnum)
            p = find(floorminute(sgram.T) == dnum(k));
            onemin(c).peakf(k) = nanmean(peakf(p));
            onemin(c).meanf(k) = nanmean(meanf(p));       
        end
    else
        sgram
    end

    print_debug(sprintf('\nCalculating derived data for %s from %s to %s',get(velocityWaveform,'station'), datestr(get(velocityWaveform,'start'),31), datestr(get(velocityWaveform,'end'),31)),2)
    onemin(c).units = get(velocityWaveform, 'units');
    onemin(c).station = get(velocityWaveform, 'station');
    onemin(c).channel = get(velocityWaveform, 'channel');    
    displacementWaveform = integrate(velocityWaveform);
    if interactive_mode
        close all;
        figure;
        plot(velocityWaveform);
        figure;
        tempw1 = integrate(velocityWaveform);
        plot(tempw1);
        figure;
        tempw2 = waveform_bandpass(tempw1, filterobject('b',[0.65 20.0],2) );
        plot(tempw2);
        figure;
        tempw3 = integrate(detrend(velocityWaveform));
        plot(tempw3);  
        figure;
        tempw4 = waveform_bandpass(tempw3, filterobject('b',[0.65 20.0],2) );
        plot(tempw4);  
        anykey;  
    end 
    
    samplingFrequency = round(get(velocityWaveform, 'freq'));
    velocityData = get(velocityWaveform, 'data');

    displacementData = get(displacementWaveform, 'data');
    samplesPerWindow = 60 * samplingFrequency;
    [snum enum] = gettimerange(velocityWaveform);
    dnum = (snum:1/1440:enum)';
    numMins = round((enum - snum) * 24 * 60);
    lenv = length(velocityData);
    lenm = samplesPerWindow*numMins;

    if (lenv > lenm)
        velocityData = velocityData(1:lenm);
        displacementData = displacementData(1:lenm); 
    end
    if (lenm > lenv) 
        z = zeros(lenm-lenv,1); % size can be different
        velocityData = catmatrices(z,velocityData);
        displacementData = catmatrices(z,displacementData);
    end
    try
        V = reshape(velocityData, samplesPerWindow, numMins); % nm/s
        D = reshape(displacementData, samplesPerWindow, numMins); % nm
    catch
        disp('reshape failed');
        numMins
        samplesPerWindow
        lenv
        lenm
        return;
    end
    onemin(c).Vmax = nanmax(abs(V), [], 1); % nm/s
    onemin(c).Vmedian = nanmedian(abs(V), 1); % nm/s
    onemin(c).Dmax = nanmax(abs(D), [], 1); % nm
    onemin(c).Dmedian = nanmedian(abs(D), 1); % nm
    onemin(c).Dmean = nanmean(abs(D), 1); % nm/s 
    onemin(c).Drms = nanmeanrms(D'); 
    onemin(c).Energy = nansum(V.*V)/samplingFrequency * 1e-6; % um^2/s
    onemin(c).dnum = dnum(1:numMins);
end
print_debug(sprintf('< %s',mfilename),2);
