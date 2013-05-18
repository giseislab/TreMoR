function we = waveform2envelope(w, span)
%WAVEFORM2ENVELOPE Create envelopes of a waveform vector, smoothing over
%span points
we = w;
for c=1:length(w)
    if get(w(c), 'data_length') == 0
       continue;
    end
    [ env ] = smooth_envelope( get(w(c), 'data'), span );
    we(c) = set(we(c), 'data', env);
end


