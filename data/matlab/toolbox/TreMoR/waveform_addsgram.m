function w=waveform_addsgram(w)
% WAVEFORM_ADDSGRAM Add a spectrogram structure to a waveform object
% w = waveform_addsgram(w);

% AUTHOR: Glenn Thompson, UAF-GI
% $Date: $
% $Revision: -1 $
for c=1:length(w)
    if isempty(get(w(c),'sgram'))
        Fs=get(w(c),'freq');
        data = get(w(c),'data');
        try
            [S,F,T] = spectrogram(data, 1024, 768, 1024, Fs);
            S=abs(S);
            sgram.S = S;
            sgram.F = F;
            sgram.T = T;
            w(c)=addfield(w(c),'sgram',sgram);
        catch
            disp('Had a problem before on 17-Apr-2009 data with length of segments longer than length of input data');
           
        end
    end
end


