function iceweb1minplot(subnet, snum, enum, station);
% ICEWEB1MINPLOT Create a customised IceWeb-like dr/drs or energy plot
%
% 	ICEWEB1MIN(VOLCANO, SNUM, ENUM) creates an IceWeb derived data plot
%       based on the station/channel list in the current parameter file for that particular
%	volcano. The start and end times are defined by the arguments SNUM and ENUM which 
%	must be in Matlab datenumber format. See DATENUM.
%
%	ICEWEB1MINPLOT(VOLCANO, SNUM, ENUM, STATION) creates an IceWeb derived data plot
%	for the STATION structure given. However, the derived data for each station/channel must
%	already exist. If they don't, see ICEWEB_DAY_WRAPPER.
%
%	A STATION structure as a bare minimum must have name and channel fields, and can be
%	constructed manually like this:
%
%		station(1).name = 'PVV';
%		station(1).channel = 'EHZ';
%		station(2).name = 'PV6';
%		station(2).channel = 'EHZ';
%		...etc
%
% 	Example:
%		The following will create an IceWeb-like spectrogram for Shishaldin Volcano 
%		from 10:00 UTC to 11:00 UTC on 10th April 2008:
%	
%  		iceweb_spectrogram('Shishaldin', datenum(2008,4,10,10,0,0), ...
%		datenum(2008,4,10,11,0,0));
%
%	Caveats:
%		No error checking has been added. Use carefully. You probably do not want to 
%		run it on more than a few hours of data!
%
%	Author:
%		Glenn Thompson (glennthompson1971@gmail.com), 2008-04-11

global PARAMS

switch nargin
	case 3,
		for c=1:length(subnets)
			if strcmp(subnets(c).name, subnet)
				station = subnets(c).stations;
			end
		end;

	case 4,
		disp('');

	otherwise
		help iceweb_derived_data_plot, return;
end

timewindow.start = snum;
timewindow.stop = enum;

disp(sprintf('You have requested a spectrogram for %s from %s to %s',subnet, datestr(snum,0), datestr(enum,0)));
debug(2);
plot1minData(subnet, station, timewindow, 'drs') 
