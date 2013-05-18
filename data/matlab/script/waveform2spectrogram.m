function waveform2spectrogram(w, s, mycmap)
% WAVEFORM2SPECTROGRAM Create a customised IceWeb-like spectrogram plot
%
% 	WAVEFORM2SPECTROGRAM(MYWAVEFORM, MYSPECTRALOBJECT, MYCOLORMAP) creates
% 	an IceWeb spectrogram plot
%
%
% 	Example:
%
%       waveform2spectrogram(w, PARAMS.spectralobject, iceweb_spectrogram_colormap);
%
%
%	Author:
%		Glenn Thompson (glennthompson1971@gmail.com), 2008-04-11
if ~exist('mycmap', 'var')
    mycmap = jet;
end

debug.set_debug(2);
    
        % downsample data
        freqmax = get(s, 'freqmax');
        for c=1:length(w)
            nyquist = get(w(c), 'freq') / 2;
            factor = floor(nyquist / freqmax);

            if (factor > 1 & (enum-snum)>60/1440)
                disp(sprintf('Decimating by factor %d',factor));

                % downsample data
                data = get(w(c),'data');
                %data2 = decimate(data, factor); % not NaN-aware
                data2 = data(1:factor:end);
                w(c) = set(w(c), 'data', data2);
                clear data data2
	
                % update the sample frequency info
                freq = get(w(c),'freq');
                freq = freq / factor;
                w(c) = set(w(c), 'freq', freq)
            end
        end

        specgram_wrapper(s, w, 0.7, mycmap);


