function waveform2sonogram(w)
% WAVEFORM2SONOGRAM Play waveform objects as sound
%
%	Author:
%		Glenn Thompson (glennthompson1971@gmail.com), 2008-04-11
close all

PARAMS.mode = 'interactive';
disp(sprintf('You have requested a sonogram from %s to %s', datestr(snum,0), datestr(enum,0)));
debug.set_debug(2);
%SPEEDUP = ceil((enum-snum)*86400/10);
SPEEDUP = 60;
wf = w;
for c=1:length(w)
            if get(w(c), 'data_length') == 0
                continue;
            end
            hf = figure;
            w(c) = demean(w(c));
            w(c) = fillgaps(w(c), 'meanall');
	    
            subplot(2,2,1),plot(w(c));
            [YfreqDomain,frequencyRange] = positiveFFT(w(c));
            subplot(2,2,2),plot(frequencyRange,abs(YfreqDomain));
            xlabel('Freq (Hz)')
            ylabel('Amplitude')
            title('Using the positiveFFT function')
            grid

	
            wf(c) = filtfilt(filterobject('b', [0.5 15.0], 3), w(c));
            subplot(2,2,3),plot(wf(c));
            [YfreqDomain,frequencyRange] = positiveFFT(wf(c));
            subplot(2,2,4),plot(frequencyRange,abs(YfreqDomain));
            xlabel('Freq (Hz)')
            ylabel('Amplitude')
            title('Using the positiveFFT function')
            grid
            
            choice = 0;
            while (choice < 4),
                choice = txtmenu('Menu:', 'play','FM + AM', 'FM', 'save', 'next', 'quit');
                switch choice
                    case 0, 
                        data = get(wf(c), 'data');
                        maxw = max(abs(data));
                        freq = get(wf(c), 'freq') * 200;
                        data = data/maxw;
                        audioPlayPlot(data, freq);
                    case 1, 
                        data = VCO_seismogram(wf(c), true, SPEEDUP);
                        %freq = get(wf(c), 'freq') * SPEEDUP;
                        freq = 1000;
                        audioPlayPlot(data, freq);
                        
                    case 2, 
                        data = VCO_seismogram(wf(c), false, SPEEDUP);
                        %freq = get(wf(c), 'freq') * SPEEDUP;
                        freq = 1000;
                        audioPlayPlot(data, freq);
                    case 3,
                        outfile = sprintf('%s_%s_%s_%s.wav',datestr(snum, 30), datestr(enum, 30), get(w(c),'station'), get(w(c),'channel'));
                        success = waveform2sound(w(c), outfile, SPEEDUP);
                    case 4,
                        % nothing to do
                    case 5, 
                        return;
                    otherwise,
                        return;
                end
            end
            close all;
end



function audioPlayPlot(y, Fs)


%% create the plot of audio samples
figure; hold on;
plot(y, 'b'); % plot audio data
title('Audio Data');
xlabel(strcat('Sample Number (fs = ', num2str(Fs), ')'));
ylabel('Amplitude');
ylimits = get(gca, 'YLim'); % get the y-axis limits
plotdata = [ylimits(1):0.1:ylimits(2)];
hline = plot(repmat(0, size(plotdata)), plotdata, 'r'); % plot the marker

%% instantiate the audioplayer object
player = audioplayer(y, Fs);

%% setup the timer for the audioplayer object
player.TimerFcn = {@plotMarker, player, gcf, plotdata}; % timer callback function (defined below)
player.TimerPeriod = 0.01; % period of the timer in seconds

%% start playing the audio
% this will move the marker over the audio plot at intervals of 0.01 s
play(player);


%% ------------------------------------------------------------------------
%% the timer callback function definition
function plotMarker(...
    obj, ...            % refers to the object that called this function (necessary parameter for all callback functions)
    eventdata, ...      % this parameter is not used but is necessary for all callback functions
    player, ...         % we pass the audioplayer object to the callback function
    figHandle, ...      % pass the figure handle also to the callback function
    plotdata)           % finally, we pass the data necessary to draw the new marker

% check if sound is playing, then only plot new marker
if strcmp(player.Running, 'on')
    
    % get the handle of current marker and delete the marker
    hMarker = findobj(figHandle, 'Color', 'r');
    delete(hMarker);
    
    % get the currently playing sample
    x = player.CurrentSample;
    
    % plot the new marker
    plot(repmat(x, size(plotdata)), plotdata, 'r');

end


function[freq,mag]=fouriertransform(w,N);
signal = get(w, 'data');
ts = 1 / get(w, 'freq');
t = datenum(w);
S=fft(signal,N);
CS=[S(N/2+1:N) S(1:N/2)];
%freq=[-N/2+1:N/2]/(N*ts);
freq=[1:N/2]/(N*ts);
length(CS)
length(freq)
mag=abs(CS)

function [X,freq]=positiveFFT(w)
x = get(w, 'data');
Fs = get(w, 'freq');
N=length(x); %get the number of points
k=0:N-1;     %create a vector from 0 to N-1
T=N/Fs;      %get the frequency interval
freq=k/T;    %create the frequency range
X=fft(x)/N; % normalize the data

%only want the first half of the FFT, since it is redundant
cutOff = ceil(N/2);

%take only the first half of the spectrum
X = X(1:cutOff);
freq = freq(1:cutOff);

function out=VCO_seismogram(w, boolAmplitudeCorrect, SPEEDUP) 
%
% Function to create Amplitude/Frequency Modulation sound file of a seismogram
% Originally created by David Simpson, December 2009
% Modified by Zhigang Peng, 2012
% Modified by Debi Kilb, May 2012
% test scale = 1; speed_factor = 100; vcof = 100; sacfile = 'BK.PKD.HHT.SAC'; 
%

%
%  Define static parameters
%
% Glenn: added this to amplitude modulation not applied by default
if ~exist('boolAmplitudeCorrect', 'var')
	boolAmplitudeCorrect = false;
end
vcof = 10; % parameter used to smooth envelope
data = get(w, 'data');
nsamp = get(w, 'freq');
delta = 1./nsamp;
time = [delta:delta:delta*length(data)];
Nf = 1/(2*delta);
filt_low_sound_vco = -inf;
filt_high_sound_vco = 0.5;
%
%  Make sure frequencies are below Nyquest
if filt_high_sound_vco>=Nf
   filt_high_sound_vco = Nf*0.99;
end
datavals = data - mean(data); % remean
max_datavals = max(abs(datavals));
datavals = datavals./max_datavals; % normalize by the maximum amplitude
%
% Now enter VCO mode 
%
%  A few notes by Debi about f_carrier: 100 is to low, 200 works well, 5000 is too high, 
%     800 sounds like 200 to me
%
fmin=8000; % not used
fmax=10000; % not used
f_carrier = 400000 / SPEEDUP 
%
% Option to resample to get a higher resolution modulating signal.
% Modulating signal length and wavwrite frequency determine final signal length
% Best to use lower resample freq and higher wavwrite freq
%    yy=resample(datavals,vcof,nsamp);
% no need to do the resampling here
%
   yy = datavals;
min(yy)
max(yy)
   yy_filt = eqfiltfilt(double(yy),filt_low_sound_vco,filt_high_sound_vco,delta,4);
   yy_filt = eqfiltfilt(double(yy),filt_low_sound_vco,filt_high_sound_vco,delta,4);
%
    zz = vco(yy,f_carrier,20000); % normalized above, no need for scaling
 %   zz = vco(yy,f_carrier,f_carrier*4); % normalized above, no need for scaling
%
% Create envelope function of the waveform using the hilbert transform
% control the volume of the sound file
%  multiply the frequcny modulated signal by the envelope to get the
%  amplitude and frequency modulated sound
%
    smooth_ev = smooth_envelope(yy,10*vcof);
    smooth_ev_filt = smooth_envelope(yy_filt,10*vcof);
    smooth_ev = smooth_ev./max(abs(smooth_ev)); % normalize
    smooth_ev_filt = smooth_ev_filt./max(abs(smooth_ev_filt)); % normalize
    smooth_combine = smooth_ev + smooth_ev_filt;
    smooth_combine = smooth_combine./(max(abs(smooth_ev_filt))); % normalize
    ayy=0.005+0.7*smooth_combine;
% Glenn: added this to amplitude modulation not applied by default
    if boolAmplitudeCorrect
    	yyy = (ayy).*(zz);
    else
    	yyy = zz;
    end
    ifplot = 1;
    if (ifplot),
       figure(10)
       clf
       subplot(3,1,1);
       plot(yy);
       axis tight
       title('Original seismogram')
       subplot(3,1,2);
       plot(ayy);
       axis tight
       title('Smoothed envelope, used as sound volume')
       subplot(3,1,3);
       plot(yyy);
       axis tight
       title('Amplitude and frequency modulated signal')
    end;
%
% Create the stereo pair by putting the original and the freq. modulated data together
% out = [yy yyy];
% apply a filter to remove the long-period signals
%
  ch1 = 0.5;
  ch2 = -inf;
  yy1=eqfiltfilt(double(yy),ch1,ch2,delta,4);
  max_yy1 = max(abs(yy1));
  yy1 = yy1./max_yy1;
% scale the high-freq. output accordly.

out = [yy1 yyy./8]; % divide the VCO signal by third to make them sounds smaller
%
%   It is important to normalize the data to be <1 and >-1:
%        data_wave_norm = data_wav/max(abs(data_wav)*1.0001);
%   before calling the MATLAB wavwrite program to avoid warnings
%   about data clipping of the form ‘Warning: data clipped during
%   write to file’.
% Glenn: overriding definition of out from a few lines above
out = yyy;
maxout = max(max(abs(out)));
out = out/(maxout*1.0001);

function filtdata = eqfiltfilt(data,ch1,ch2,dt,ih)
%filtdata = eqfiltfilt(data,ch1,ch2,dt,ih)
%	Function to perform butterworth	filter on "data"
%	vector,	and return filtered data vector	"filtdata"
%
%	filter corners (above "ch1" and	below "ch2" can	pass, in Hz)
%	  if ch1 < 0,	    % LOW-PASS FILTER  (-inf,ch2)
%	  elseif ch2 < 0,   % HIGH-PASS	FILTER (ch1,inf)
%	  elseif ch1 > ch2, % BAND-STOP	FILTER (-inf,ch2) & (ch1,inf)
%	  else		    % BAND-PASS	FILTER (ch1,ch2)
%	sampling rate (dt, in sec/sample)
%	butterworth filter order (ih, default =	4)

%
% Last update 5/2/97, Cheng-Ping Li
% Modified by Zhigang Peng, Mon Oct 14 17:04:30 PDT 2002

if nargin <= 4,	ih=4; end
if nargin <= 3,	dt=1; end
if nargin <= 2,	
	error(['Not enough input argument, (at least 3,	data ch1, and ch2)']); 
end
samp = 1/dt;		% sampling frequency
ch1n = ch1*2/samp;
ch2n = ch2*2/samp;

if ch1 < 0,			% LOW-PASS FILTER
  [b,a]	= butter(ih,ch2n);
elseif ch2 < 0,			% HIGH-PASS FILTER
  [b,a]	= butter(ih,ch1n,'high');
elseif ch1 > ch2,		% BAND-STOP FILTER
  [b,a]	= butter(ih,[ch2n ch1n],'stop');
else				% BAND-PASS FILTER
  [b,a]	= butter(ih,[ch1n ch2n]);
end

filtdata = filtfilt(b,a,data); % zero phase filter the data



