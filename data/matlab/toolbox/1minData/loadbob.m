function onemin = loadbob(station, snum, enum, measure, datadir);
% onemin = loadbob(station, snum, enum, measure, datadir);
%
% Purpose:
%	Loads derived data from a binary file in the BOB RSAM format
%	Path is like $paths.DERIVED_DATA/measure/subnet
%	Filename is like $stationName$YEAR.dat
%	The pointer position at which to reading from the binary file is determined timewindow.start. 
%	Load all the data in the timewindow given. So if timewindow is 12:34:56 to 12:44:56, 
%	it is the samples at 12:35, ..., 12:44 - i.e. 10 of them.
%       If the timewindow requested spans a year boundary, it will read from all the binary files.
%	importBinary is the function that reads the binary file. load1minfile is a wrapper to that. 
%	
% Input:
% 	subnet - the volcano network name, used as part of the path.
% 	sta - the station name, used as part of the filename
%	snum, enum - a Matlab datenum representing the start/end date/time.
%	measure - a string which identifies the measurement type
%               - examples include dr, drs, en, tdr, tdrs, tmdr, tmdrs
%
% Output:
%	onemin.dnum 
%	onemin.data
%	onemin.datafound
%	onemin.station.name
%	onemin.subnet
%	onemin.snum
%	onemin.enum
%	onemin.measure
%
% Author:
% 	Glenn Thompson, MVO/AVO, 2000 - 2009 

% import paths
global paths;

sta = station.name
chan = station.channel


% initialise output variables
onemin.station = station;
onemin.snum = snum;
onemin.enum = enum;
onemin.measure= measure;
onemin.dnum=[];
onemin.data=[];
onemin.datafound=0;
onemin.use = false;

% set start year and month, and end year and month
[syyy sm]=datevec(snum);
[eyyy em]=datevec(enum);

filebase =  catpath(datadir, sprintf('%s_%s_%s',sta,chan,measure));

% load the data
for yyyy=syyy:eyyy
    
   % Check year against start year 
   if yyyy~=syyy
      % if not the first year, start on 1st Jan
      yrsnum=datenum(yyyy,1,1);
   else
	yrsnum=snum;
   end
   
   % Check year against end year
   if yyyy~=eyyy
      % if not the last year, end at 31st Dec
      yrenum=datenum(yyyy,12,31,23,59,59);
   else
	yrenum = enum;
   end   
   
   % Set path to data file
   infile =  sprintf('%s_%d.bob',filebase, yyyy)

   if exist(infile, 'file')
	   % Import the data for this year
	   [dnum, data, onemin.datafound] = import1minfile(infile, yrsnum, yrenum);

	   % Now paste together the matrices
		if onemin.datafound
	   		onemin.dnum = catmatrices(dnum, onemin.dnum);
	  		onemin.data = catmatrices(data, onemin.data);
		end
    end   
end


% reset the datafound flag - in case last year was a blank
if length(find(onemin.data>0)) > 0
    onemin.datafound = 1;
    onemin.use = true;
else
	print_debug(sprintf('%s: No data loaded from file %s',mfilename,infile),1);
end



clipOn = 0;
if clipOn==1
% clip the data depending on type
if strfind(measure,'dr')
	i = find(onemin.data>500);
	onemin.data(i)=NaN;
end

if strfind(measure,'isp')
	i = find(onemin.data>0.01);
	onemin.data(i)=NaN;
end

if strfind(measure, 'td')
	i = find(onemin.data>0.01);
	onemin.data(i)=NaN;
end

if strfind(measure,'rsam')
	i = find(onemin.data>0.01);
	onemin.data(i)=NaN;
end

if strfind(measure,'en')
	i = find(onemin.data>0.0001);
	onemin.data(i)=NaN;
end
end

% eliminate any data outside range asked for
i = find(onemin.dnum >= snum & onemin.dnum <= enum);
onemin.dnum = onemin.dnum(i);
onemin.data = onemin.data(i);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555

function [dnum, data, datafound] = import1minfile(infile, snum, enum);

datapointsperday = 1440;

% initialise return variables
datafound=0;
dnum=[];
data=[];


[yyyy mm]=datevec(snum);
days=365;
if mod(yyyy,4)==0
	days=366;
end

startsample=ceil((snum-datenum(yyyy,1,1))*datapointsperday);
endsample =floor((enum-datenum(yyyy,1,1))*datapointsperday);
nsamples = endsample - startsample;

% now ready to create dnum vector
dnum = ceilminute(snum)+(0:nsamples-1)/datapointsperday;

if ~exist(infile,'file')	
   % infile doesn't exist
   print_debug(['No file ',infile],1)
   data(1:length(dnum))=NaN;
   
else
   % file found
   print_debug(sprintf( 'Loading data from %s, position %d to %d of %d', ...
	infile, startsample,(startsample+nsamples-1),(datapointsperday*days) ),3); 
   
   %fid=fopen(infile,'r', 'b'); % big-endian for Sun, little-endian for PC
   fid=fopen(infile,'r', 'l'); % big-endian for Sun, little-endian for PC

   % Position the pointer
   offset=(startsample)*4;
   fseek(fid,offset,'bof');
   
   % Read the data
   [data,numlines] = fread(fid, nsamples, 'float32');
   fclose(fid);
   datafound=0;
   print_debug(sprintf('mean of data loaded is %e',nanmean(data)),1);
   
   % Transpose to give same dimensions as dnum
   data=data';

   % Test for Nulls
   if length(find(data>0)) > 0
	datafound=1;
   end	

   
end

return;



