function save2bob(sta, chan, dnum, data, measure);
% save2bob(sta, chan, dnum, data, measure)
%
% Purpose:
%	Saves 1 minute data to a binary file in the BOB RSAM format 
%
% Input:
% 	sta - the station name, used as part of the filename.
%   chan - the channel name, e.g. EHZ
%	dnum - the time vector in Matlab datenum format. 
%	     - only the first value is used as 1 minute sampling is assumed.	
%	data - the vector of data values. 1 minute sampling is assumed.
%	measure - a string which identifies the measurement type. 
%               - examples include dr, drs, en, tdr, tdrs, tmdr, tmdrs
%
% Author:
% 	Glenn Thompson, MVO/AVO, 2000 - 2009 

global paths ;
print_debug(sprintf('> %s', mfilename),4)
if isa(sta, 'cell')
	sta=sta{1};
end
if isa(chan, 'cell')
	chan=chan{1};
end
% write data
if ~exist(paths.ONEMINDATA, 'dir')
        mkdir(paths.ONEMINDATA);
end
fname =  catpath(paths.ONEMINDATA, sprintf('%s_%s_%s',sta,chan,measure));
write2bob(dnum, data, fname);

print_debug(sprintf('< %s', mfilename),4)
