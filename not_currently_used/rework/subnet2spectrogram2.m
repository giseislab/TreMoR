function subnet2spectrogram(arg1, arg2, arg3, arg4)
% subnet2spectrogram 
% Two ways of calling this function
% 	1. subnet2spectrogram(subnet, w, outputfilename)
% 	2. subnet2spectrogram(subnet, w, outputfilename, timewindow)
%
% This Matlab function creates a spectrogram for a subnet (e.g. a volcano network) of seismic stations
% 
% subnet2spectrogram(subnet, station, outputfilename, timewindow)
%	subnet 		- name of the sub network
%	station 	- this is a structure which has fields including a station name and channel. 
% 	timewindow 	- a structure with two fields, start and stop. These are in datenum format. Start and end of plot will be
%                         bound by these times.
%	w 		- a waveform object, or a vector of waveform objects
%       outputfilename  - the full path to save the plot file to
%
% Based on spectrograms.m - part of IceWeb since 1998 - but rewritten in a way so it can be called from the Matlab prompt
% or a graphical user interface, as well as from a cronjob. This enables users to create custom IceWeb spectrograms
%
% Uses spectralobject/specgram
% TO DO:
%   Support the constructor:
%	specgram3(w, title, s [, clim [, cmap]]) where w is an array of waveforms.
%       clim gives the dbmin & dbmax (default is to autoscale). cmap changes the colormap.
%
% Glenn Thompson, 1998-2009
%
global PARAMS paths;
print_debug(sprintf('> %s', mfilename),1)

switch nargin
  	case 2,
		[subnet, w] = deal(arg1, arg2);
		timewindow = waveform2timewindow(w);
	case 3, 
		[subnet, w, outputfilename] = deal(arg1, arg2, arg3);
		timewindow = waveform2timewindow(w);
	case 4	
		[subnet, w, outputfilename, timewindow] = deal(arg1, arg2, arg3, arg4);
 	otherwise return;
end


warning off; % suppress log of 0 warning if no data

% close all previous plots
close all;

% find where minute marks go
[Xtickmarks, Xticklabels] = findMinuteMarks(timewindow);

% loop over stations
numStations=length(w);

% title
title = [subnet,'  ',datestr(timewindow.start,31),' - ',datestr(timewindow.stop,13),' UTC'];

% plot iceweb-like spectrogram
specgram3(w, title, PARAMS.spectralobject);

% add colorbar
PARAMS.colorbar=0;
if (PARAMS.colorbar == 1)
	addColorbar(PARAMS.dbValueForBlue, PARAMS.dbValueForRed);
end

% save image file
orient tall;
if (PARAMS.print == 1) 
	try
		saveImageFile(outputfilename, 60);
	catch
		disp(sprintf('Could not save %s',outputfilename));
	end
end

print_debug(sprintf('< %s', mfilename),1)



