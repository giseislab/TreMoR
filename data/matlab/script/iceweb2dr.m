w=iceweb2waveform('pf/tremor_runtime.mat', 'Pavlof', datenum(2013,5,16,0,0,0), datenum(2013,5,16,1,0,0));
wf = waveform2filteredwaveform(w, 0.5, 10.0, 2);
%we = waveform2envelope(wf, 1000);
close all
for c=1:length(wf)
    lambda = 1.67; % in km
        factor = 1e-7 .* sqrt( (1e5 * get(w(c), 'distance')) *(1e5*lambda) );
        drs = get(w(c), 'data') * factor;

    subplot(length(wf), 1, c), plot(drs);
end

    % This is Mike's version but it integrates over whole waveform to a
    % single measurement
%for c=1:length(wf)
%    w(c) = reduced_disp( w(c),get(w(c), 'distance'));
%    dr = get(w(c), 'reducedisp');
%    subplot(length(wf), 1, c), plot(dr);
%end