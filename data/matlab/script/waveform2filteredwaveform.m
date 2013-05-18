function wf = waveform2filteredwaveform(w, lowpass, highpass, npoles)
%WAVEFORM2FILTEREDWAVEFORM Summary of this function goes here
%   Bandpass filter a waveform vector (demean and fillgaps with mean first)
wf = w;
for c=1:length(w)
    if get(w(c), 'data_length') == 0
       continue;
    end
    w(c) = demean(w(c));
    w(c) = fillgaps(w(c), 'meanall');
    wf(c) = filtfilt(filterobject('b', [lowpass highpass], npoles), w(c));
end


