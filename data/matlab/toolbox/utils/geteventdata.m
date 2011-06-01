function event_struct = db2event(snum, enum, mthresh, region, db, archiveformat);
% event = db2event(snum, enum, mthresh, region, db, archiveformat);
%
% db2event is a wrapper for db2event that uses regions from avo_volcs.pf
%
% PARAMETERS:  
% snum = start time/date in datenumber format  
% enum = end time/date in datenumber format  
% mthresh will cut out events smaller than this magnitude  
% region - examples are 'redoubt', 'spurr' and 'alaska' (must be defined in avo_volcs.pf) 
% Alternatively region can be a 4-element vector like: [leftlon rightlon lowerlat upperlat].
% db - path of the database (root path to a monthly or daily database)
% archiveformat	- leave blank if its a normal database, otherwise 'daily' for a daily archive, 'monthly' for a monthly archive
% 
% Example:
%   Last 3 days of data from a daily archive
%   event = db2event(utnow-3, utnow, -0.5, 'redoubt', 'dbquakes/quakes', 'daily');
%
% Author: Glenn Thompson, 2002-2009
  
print_debug(sprintf('> %s',mfilename),2); 

if nargin<5
	error('Not enough arguments');
	return;
end
  
if ~exist('archiveformat','var')  
    archiveformat = '';  
end
print_debug(sprintf('archive format is %s',archiveformat),5);
  
% Check if region is a char (string) or double (array) class
if strcmp(class(region),'char')
	[sourcelon, sourcelat, leftlon, rightlon, lowerlat, upperlat] = readavovolcs(region, pffile); 
	event_struct.regionname = region;
else
	if strcmp(class(region),'double')
		leftlon = region(1); rightlon=region(2); lowerlat=region(3); upperlat=region(4);
	end
end
mindepth = 0;
maxdepth = 50;
		
event_struct = loadevent(db, archiveformat, snum, enum, leftlon, rightlon, lowerlat, upperlat, mindepth, maxdepth, mthresh);

% Append input parameters to structure
event_struct.snum = snum;
event_struct.enum = enum;
event_struct.magthreshold = mthresh;
event_struct.region = [leftlon rightlon lowerlat upperlat];
event_struct.dbroot = db;
event_struct.archiveformat = archiveformat;

print_debug(sprintf('< %s',mfilename),2); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
function event_struct = loadevent(dbroot,archiveformat,snum,enum,leftlon,rightlon,lowerlat,upperlat,minz,maxz,minmag);
% DB2EVENT is a Matlab function to retrieve event parameters from a Datascope database
% event = loadevent(dbroot,archiveformat,snum,enum,leftlon,rightlon,lowerlat,upperlat,minz,maxz,minmag)  
%
% INPUT:
%	dbroot			the path of the database
%	archiveformat		leave blank if its a normal database, otherwise 'daily' for a daily archive, 'monthly' for a monthly archive
%	snum,enum		start and end datenumbers (Matlab time format, see 'help datenum')
%	leftlon, rightlon	longitude range in decimal degrees (west is negative, range is -180 to 180)
%	lowerlat, upperlat	latitude range in decimal degrees (southern hemisphere is negative, range is -90 to 90)
%	minz, maxz		depth range (below sea level) in kilometres
%	minmag			minimum magnitude (mb, ml, ms)
%
%
% OUTPUT:
%	event			a structure containing the fields lat, lon, depth, time, evid, nass and mag for each event meeting the selection criteria
%
% Example:
%	e = db2event('dbseg/Quakes','daily',datenum(2009,1,25),datenum(2009,7,1),-179,179,-89,89,0,30,-0.5);
%
% Glenn Thompson, 20070406

event_struct.lon   = [];
event_struct.lat   = [];
event_struct.depth = [];
event_struct.dnum  = [];
event_struct.nass  = [];
event_struct.evid  = [];
event_struct.mag   = [];
event_struct.etype  = '';

if ~exist('minmag','var')
	minmag = -999.0;
end

print_debug(sprintf('archive format is %s',archiveformat),5);

if strcmp(archiveformat,'')
	dbname = dbroot;
	if exist(dbname,'file')
		event = dbimport2event(snum, enum, dbname, leftlon, rightlon, lowerlat, upperlat, minz, maxz, minmag);
	else
		disp(sprintf('database %s not found',dbname));
	end
else
	if strcmp(archiveformat,'daily')
		for dnum=floor(snum):floor(enum-1/1440)
			[yr,mn,dy]=yyyymmdd(dnum);
			dbname = sprintf('%s_%s_%s_%s',dbroot,yr,mn,dy);
			if exist(dbname,'file')
				e = dbimport2event(max([dnum snum]),min([dnum+1 enum]),dbname,leftlon,rightlon,lowerlat,upperlat,minz,maxz,minmag);
				event_struct.lon   = cat(1,event_struct.lon,   e.lon);
				event_struct.lat   = cat(1,event_struct.lat,   e.lat);
				event_struct.depth = cat(1,event_struct.depth, e.depth);
				event_struct.dnum  = cat(1,event_struct.dnum,  e.dnum);
				event_struct.evid  = cat(1,event_struct.evid,  e.evid);
				event_struct.nass  = cat(1,event_struct.nass,  e.nass);
				event_struct.mag   = cat(1,event_struct.mag,   e.mag);
				event_struct.etype  = cat(1,event_struct.etype,  e.etype);
			else
				disp(sprintf('database %s not found',dbname));
			end
		end
	else

		for yyyy=dnum2year(snum):1:dnum2year(enum)
			for mm=dnum2month(snum):1:dnum2month(enum)
				dnum = datenum(yyyy,mm,1);
				dbname = sprintf('%s%04d_%02d',dbroot,yyyy,mm);
				if exist(dbname,'file')
					e = dbimport2event(max([dnum snum]),min([ datenum(yyyy,mm+1,1) enum]),dbname,leftlon,rightlon,lowerlat,upperlat,minz,maxz,minmag);
					event_struct.lon   = cat(1,event_struct.lon,   e.lon);
					event_struct.lat   = cat(1,event_struct.lat,   e.lat);
					event_struct.depth = cat(1,event_struct.depth, e.depth);
					event_struct.dnum  = cat(1,event_struct.dnum,  e.dnum);
					event_struct.evid  = cat(1,event_struct.evid,  e.evid);
					event_struct.nass  = cat(1,event_struct.nass,  e.nass);
					event_struct.mag   = cat(1,event_struct.mag,   e.mag);
					event_struct.etypes  = cat(1,event_struct.etypes,  e.etypes);
				else
					disp(sprintf('database %s not found',dbname));
				end
			end
		end
	end
end

% eliminate bogus magnitudes
i = find(event_struct.mag > 10.0);
event_struct.mag(i)=NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function event_struct = dbimport2event(snum,enum,dbname,leftlon,rightlon,lowerlat,upperlat,minz,maxz,minmag)

print_debug(sprintf('> dbimport2event'),2);


lon=[];lat=[];depth=[];dnum=[];evid=[];nass=[];mag=[];etype=[];

% create blank event structure
event_struct.lon   = lon;
event_struct.lat   = lat;
event_struct.depth = depth;
event_struct.dnum  = dnum;
event_struct.nass  = nass;
event_struct.evid  = evid;
event_struct.mag   = mag;
event_struct.etype  = etype;

print_debug(sprintf('Loading data from %s',dbname),1);

% First, lets get a summary of origins
try
	db = dbopen(dbname, 'r');
catch
	if ~exist(dbname, 'file')
		disp(sprintf('%s does not exist',dbname));
	else
		disp(sprintf('Could not open %s',dbname));
	end
    	return;
end

db = dblookup_table(db, 'origin');
if (dbquery(db, 'dbRECORD_COUNT')==0)
	if ~exist([dbname,'.origin'], 'file')
		disp(sprintf('%s.origin does not exist',dbname));
	else
		disp(sprintf('Could not open %s.origin',dbname));
	end
	return;
end
db = dbjoin(db, dblookup_table(db, 'event') );
db = dbsubset(db, 'orid == prefor');
db = dbsort(db, 'time');

numprefors = dbquery(db,'dbRECORD_COUNT');
print_debug(sprintf('Got %d prefors prior to subsetting',numprefors),2);
	
% Do the subsetting
if exist('minmag','var')
	expression_mag  = sprintf(' mb    >= %f  || ml    >=  %f || ms >=  %f',minmag,minmag,minmag);
	db = dbsubset(db, expression_mag);
end


numevents = dbquery(db,'dbRECORD_COUNT');
print_debug(sprintf('Got %d prefors after mag subsetting (%s)',numevents, expression_mag),2);
minepoch = datenum2epoch(snum);
maxepoch = datenum2epoch(enum);
expression_time = '';
expression_time = sprintf('time  >= %f && time  <= %f',minepoch,maxepoch);
try
	db = dbsubset(db, expression_time);
catch
	error(sprintf('%s: dbsubset: %s',mfilename, expression_time));
end


numevents = dbquery(db,'dbRECORD_COUNT');
print_debug(sprintf('Got %d prefors after time subsetting',numevents),2);
if exist('upperlat','var')
	expression_lat  = sprintf('lat   >= %f  && lat   <= %f',lowerlat,upperlat);
	db = dbsubset(db, expression_lat);
end

if exist('rightlon','var')
	if (leftlon < rightlon) 
		% does not span the 180 degree discontinuity
		expression_lon  = sprintf('lon   >= %f  && lon   <= %f',leftlon,rightlon);
	else
		% does span the 180 degree discontinuity
		expression_lon  = sprintf('lon   >= %f  || lon   <= %f',leftlon,rightlon);
	end
	db = dbsubset(db, expression_lon);
end


numevents = dbquery(db,'dbRECORD_COUNT');

print_debug(sprintf('Got %d prefors after region subsetting (%s && %s)',numevents,expression_lon,expression_lat),2);

if exist('maxz','var')
	expression_z    = sprintf('depth >= %f    && depth <=  %f',minz,maxz);
	db = dbsubset(db, expression_z);
end

nEvents = dbquery(db, 'dbRECORD_COUNT');
print_debug(sprintf('Got %d prefors after depth subsetting (%s)',numevents,expression_z),2);
print_debug(sprintf('Reading %d events from %s between  %s and %s', nEvents, dbname, datestr(snum,0), datestr(enum, 0)),1); 


if nEvents>0
	[lat0, lon0, depth0, time0, evid0, nass0, ml0, mb0, ms0] = dbgetv(db,'lat', 'lon', 'depth', 'time', 'evid', 'nass', 'ml', 'mb', 'ms');
	try
		etype0 = dbgetv(db,'etype');
    	end
     
    	if isempty(etype0)
        	etype0=char(ones(nEvents,1)*'R');
    	else
       		% convert etypes
		etype0=char(etype0);
		i=find(etype0=='a');
		etype(i)='t';
		i=find(etype0=='b');
		etype0(i)='l';
		i=find(etype0=='-');
		etype0(i)='u';  
    	end

	% get mag
	mag0 = max([ml0 mb0 ms0], [], 2);

    	% convert time from epoch to Matlab datenumber
	dnum0 = epoch2datenum(time0);

	% concatenate matrices
	%lon   = cat(1,lon,   lon0);
	%lat   = cat(1,lat,   lat0);
	%depth = cat(1,depth, depth0);
	%dnum  = cat(1,dnum,  dnum0);
	%evid  = cat(1,evid,  evid0);
	%nass  = cat(1,nass,  nass0);
	%mag   = cat(1,mag,   mag0);
	%etype  = cat(1,etype,  etype0);
	lon   = catmatrices(lon0,   lon);
	lat   = catmatrices(lat0,   lat);
	depth = catmatrices(depth0, depth);
	dnum  = catmatrices(dnum0,  dnum);
	evid  = catmatrices(evid0,  evid);
	nass  = catmatrices(nass0,  nass);
	mag   = catmatrices(mag0,   mag);
	etype  = catmatrices(etype0,  etype);

end

	
% close database
dbclose(db);

% create event structure
event_struct.lon   = lon;
event_struct.lat   = lat;
event_struct.depth = depth;
event_struct.dnum  = dnum;
event_struct.nass  = nass;
event_struct.evid  = evid;
event_struct.mag   = mag;
event_struct.etype  = etype;


print_debug(sprintf('< dbimport2event'),2);
return;  
  
  
  
