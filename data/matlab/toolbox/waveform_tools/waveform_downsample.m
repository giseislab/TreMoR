function w=waveform_downsample(w, downsample_method)
% Note: If RMS and STD were added as methods to waveform/resample, this
% function would be obsolete
% downsample to 1 Hz
data = abs(get(w,'data'));
tstart = get(w, 'tstart');
Fs = get(w, 'freq');
l = length(data);
count = 1;
seconds = 60;
step = Fs * seconds;
for ssamp=1:step:l
    esamp = min([(ssamp + step -1) l]);
    y(count) = eval(sprintf('%s(data(ssamp:esamp))',downsample_method));
    count = count + 1;
end 
w = set(w, 'data', y, 'freq', 1/seconds);
w = addfield(w, 'downsample_method', downsample_method);
w = addHistory(w, sprintf('Resampled data using %s method in %s',downsample_method,mfilename));