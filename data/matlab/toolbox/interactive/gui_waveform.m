function w=gui_waveform(subnet, station, channel, snum, enum, varargin)
[remove_calibs, remove_spikes, remove_trend, remove_response, interactive_mode, lowcut, highcut] = process_options(varargin, 'remove_calibs', true, 'remove_spikes', true, 'remove_trend', true, 'remove_response', false, 'interactive_mode', false, 'lowcut', 0.5, 'highcut', 20.0);

% load the data
w=waveform_load(subnet, station, channel, snum, enum, 'remove_calibs', remove_calibs, 'remove_spikes', remove_spikes, 'remove_trend', remove_trend, 'remove_response', remove_response, 'interactive_mode', interactive_mode, 'lowcut', lowcut, 'highcut', highcut);

% plot it
fh=figure;
plot(w, 'xunit', 'date');axis tight;

% now add menubar
sgram = get(w, 'sgram');  
%set(gcf,'MenuBar','none');
analmh = uimenu(fh, 'Label', 'Analyse');
uimenu(analmh, 'Label', 'Spectrogram', 'Callback', {@sgram_callback, sgram, lowcut, highcut});
uimenu(analmh, 'Label', 'Frequency', 'Callback', {@f_callback, sgram});    
reddispmh=uimenu(analmh,'Label', 'Reduced displacement');
drmh=uimenu(reddispmh,'Label', 'Body wave');
uimenu(drmh,'Label', 'Max', 'Callback', {@dr_callback, w, subnet, 'body', 'absmax'});
uimenu(drmh,'Label', 'Mean', 'Callback', {@dr_callback, w, subnet, 'body', 'absmean'});
uimenu(drmh,'Label', 'Median', 'Callback', {@dr_callback, w, subnet, 'body', 'absmedian'});
uimenu(drmh,'Label', 'RMS', 'Callback', {@dr_callback, w, subnet, 'body', 'rms'});
drsmh=uimenu(reddispmh,'Label', 'Surface wave');
uimenu(drsmh,'Label', 'Max', 'Callback', {@dr_callback, w, subnet, 'surface', 'absmax'});
uimenu(drsmh,'Label', 'Mean', 'Callback', {@dr_callback, w, subnet, 'surface', 'absmean'});
uimenu(drsmh,'Label', 'Median', 'Callback', {@dr_callback, w, subnet, 'surface', 'absmedian'});
uimenu(drsmh,'Label', 'RMS', 'Callback', {@dr_callback, w, subnet, 'surface', 'rms'});
uimenu(analmh,'Label', 'Power Spectral Density', 'Callback', {@psd_callback, w});
uimenu(analmh,'Label', 'Cumulative Energy', 'Callback', {@energy_callback, w});


% CALLBACKS START HERE

function sgram_callback(hObject, eventdata, sgram, lowcut, highcut)
figure;
imagesc(sgram.T, sgram.F, sgram.S);
axis tight;
set(gca,'YLim',[lowcut highcut]);
ylabel('freq');
xlabel('Seconds');

function f_callback(hObject, eventdata, sgram)
figure;
[Smax, i] = max(sgram.S);
peakf = sgram.F(i);
j = find(i>1);
peakf2=peakf(j);
peakf2_t=sgram.T(j);
plot(peakf2_t, peakf2);ylabel('freq (Hz)');
hold on;
meanf = (sgram.F' * sgram.S)./sum(sgram.S);
plot(sgram.T, meanf,'r');axis tight;
legend('peakf','meanf');

function dr_callback(hObject, eventdata, w, subnet, wave_type, downsample_method)
%
% get frequency
prompt={'Enter frequency to use'};
name='';
numlines=1;
defaultanswer={'2.0'};
answer = inputdlg(prompt,name,numlines,defaultanswer);
f = str2num(answer{1});
%
% convert to a downsampled Dr waveform
w = waveform_computeDr(w, subnet, f, 'downsample_method', downsample_method, 'wave_type', wave_type);
% 
% plot it
figure;
%subplot(3,1,1), plot(w, 'xunit', 'date');
plot(w, 'xunit', 'date');
ylabel('D_R_S (cm^2)');axis tight;
%
% compute seismic moment rate (in W) = 1e12 DR or 6e11 DRS (Fehler, 1983)
% Note this is for a particular geometry at St Helens or Hawaii
%w = set(w,'data',get(w,'data')*6e11);
%subplot(3,1,2), plot(w);
%ylabel('seismic moment rate (W)');
%
% compute seismic moment rate (in W) = 1e12 DR or 6e11 DRS (Fehler, 1983)
% Note this is for a particular geometry at St Helens or Hawaii
%w = set(w,'data',cumsum(get(w,'data'))/get(w,'freq') );
%subplot(3,1,3), plot(w);
%ylabel('seismic moment (J)');



function psd_callback(hObject, eventdata, w)
Fs = get(w,'freq');
x = get(w,'data');
h=spectrum.welch;
Hpsd=psd(h,x,'Fs',Fs);
figure;
plot(Hpsd);
%axis tight;

function energy_callback(hObject, eventdata, w)
% compute energy and put into a waveform
w = waveform_computeCumulativeEnergy(w);
%
% plot
figure;
plot(w, 'xunit', 'date');axis tight;
disp('Click two points with the mouse and report time and energy difference as well as average amplitude');
again=1;
while again
    [x,y]=ginput(2);
    disp(sprintf('Start\t%s\nEnd:\t%s\nDuration:\t%s\nEnergy:\t%e\nAv. amp:\t%e\n', ...
        datestr(x(1),31), datestr(x(2), 31), datestr(x(2)-x(1), 13), y(2)-y(1), sqrt( (y(2)-y(1))/((x(2)-x(1))*86400)) ));
   
    if ~exist('energy.dat','file')
        fid = fopen('energy.dat','a');
        fprintf(fid, 'Start:\tEnd:\tDuration:\tEnergy:\tAv. amp:\n');
    end
    fid = fopen('energy.dat','a');
    fprintf(fid,'%s\t%s\t%s\t%e\t%e\n',datestr(x(1),31), datestr(x(2), 31), datestr(x(2)-x(1), 13), y(2)-y(1), sqrt( (y(2)-y(1))/((x(2)-x(1))*86400)));
    fclose(fid);
    again = menu('Another measurement?','no', 'yes');
    again = again - 1;
    
end





























