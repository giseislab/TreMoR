function w = bandpass(w, filterObj, varargin);
% BANDPASS Bandpass a waveform object
% 	w = bandpass(w, filterobject);
%
%	w = bandpass(w, filterobject, 'pad', true)
%		for stability, pad the waveform with itself on both ends prior to filtering
%		and then tapering.
%
% 	See also: filterobject, filtfilt, response_apply.

% AUTHOR: Glenn Thompson, UAF-GI
% $Date: $
% $Revision: -1 $
[pad] = process_options(varargin, 'pad', true);
if numel(w)>1
    for c=1:numel(w)
           w(c) = waveform_bandpass(w(c), filterObj, 'pad', pad);
           return;
    end
end
         

% PREPARE VARIABLE SPACE
filterBand = get(filterObj,'CUTOFF');
period = get(w,'PERIOD');
nyquist = get(w,'NYQ');
rawData = double(w);
dataLength = numel(rawData);
rawData = reshape(rawData,1,dataLength);    


if pad
    % PREPARE TRACE DATA
    % Create a zero padded Tukey taper
    %    Taper size is determined by the high pass filter frequency
    %    Tapered waveform is zeros padded on either end to triple the trace length
    taperFullWidth = round(0.5/(filterBand(1)*period))*2; % guarantees an even number
    taperAmp = hanning(taperFullWidth)';
    taperAmp = [taperAmp(1:(taperFullWidth/2)) ones(1,(dataLength-taperFullWidth)) taperAmp(((taperFullWidth/2)+1):taperFullWidth)];
    taperAmp = [ zeros(1,dataLength) taperAmp zeros(1,dataLength) ];
    rawData = [ zeros(1,dataLength) rawData zeros(1,dataLength) ].*taperAmp;
    dataLength = numel(rawData);
end

% FILTER THE DATA
[z q] = butter(get(filterObj,'POLES'),[(filterBand(1)/nyquist) (filterBand(2)/nyquist)]);
newData = filter(z,q,rawData);
newData = filter(z,q,fliplr(newData)); % filter both ways
newData = fliplr(newData);

% REMOVE TRACE PADDING
if pad
    newData = newData( (dataLength/3)+1 : 2*(dataLength/3) );
end

% RETURN FILTERED WAVEFORM
w = set(w,'DATA',newData);
w = addhistory(w,'This waveform has been bandpassed between %f and %f Hz.',filterBand);

