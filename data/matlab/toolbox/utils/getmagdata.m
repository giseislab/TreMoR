function [cdnum, ccts, cmag, total_counts, total_magnitude, datafound] = getmagdata(snum, enum, binsize, threshold_mag, subclasses_selected, region, db, archiveformat);
% [dnum, mag, cts, total_cts, total_mag, datafound] = getmagdata(snum, enum, binsize, threshold_mag, subclasses_selected, region, db, archiveformat);
%
% getmagdata is a utility for reading data from an event catalog in either MVO catalog or Antelope format
% It is a wrapper for mvocatalog2mag (for Montserrat/Seisan data) and geteventdata/event2mag (for Antelope data)
%
% PARAMETERS:  
% snum = start time/date in datenumber format  
% enum = end time/date in datenumber format  
% binsize is in days (0 produces stem plots).  
% threshold_mag will cut out events smaller than this magnitude  
%  
% subclasses_selected
% -------------------
% Valid strings are any combination of the characters 'r', 'l', 'h', 't' or 'u'  
% For Montserrat catalog subclasses are 'r', 'e', 'l', 'h', 't' and 'R' 
% For AEIC only subclass is 'R'  
% For AVO analyst-reviewed catalog subclasses include 't' and 'l'  
% For AVO real-time catalog only subclass is 'u' (unclassified)
%
% region - examples are 'montserrat', 'redoubt', 'spurr' and 'alaska'
% regions other than 'montserrat' must be defined in avo_volcs.pf 
%
% For Montserrat data:  
% mvocatalog2mag takes magnitude data computed with magnitudes.pl for each event
%
% Example 1:  
%   to get mag data with binsize 1 day, for subclasses 'rlht', for the  
%   date range 1 Jan 2003 to 1 Apr 2003, and eliminating events smaller  
%   than M=1.0:
%   [dnum, cts, mag, tcts, tmag] = getmagdata(datenum(2003,1,1), datenum(2003,4,1), 1.0, 1.0, 'rlht', 'montserrat');  
%  
% Example 2: 
%   All BB dataset, weekly bins, counts & magnitude plots, threshold 0.2  
%   [dnum, cts, mag, tcts, tmag] = getmagdata(datenum(1996,11,1), datenum(2004,2,1), 7.0, 0.2, 'rlht', 'montserrat');
%
% For AEIC/AVO data:  
%	db			path of the database (root path to a monthly or daily database)
%	archiveformat		leave blank if its a normal database, otherwise 'daily' for a daily archive, 'monthly' for a monthly archive
% 
% Example 3:
%   Last 3 days of data from a daily archive
%   [dnum, cts, mag, tcts, tmag] = getmagdata(utnow-3, utnow, 1, -0.5, 'u', 'redoubt', 'dbseg/Quakes', 'daily');
%
% Author: Glenn Thompson, 2002-2010
  

print_debug(sprintf('> %s',mfilename),2); 
print_debug(sprintf('archive format is %s',archiveformat),5);
cdnum =[]; ccts = []; cmag = []; total_counts= []; total_magnitude = []; datafound = 0;
  
numdays=enum-snum;  
if numdays<binsize*3  
    error('Silly choice of date range and binsize');  
end  
  
% plot the subclasses requested by the user, or use the default  
if ~exist('subclasses_selected','var')  
    subclasses_selected='relhtR';  
end  
  
if ~exist('db','var')  
    region = 'montserrat';  
end  

if ~exist('archiveformat','var')  
    archiveformat = '';  
end
  
% load the magnitude data for a given date range, filtering out events  
% below a certain threshold magnitude  
  
if strcmp(region, 'montserrat')  
	event=[];
	disp('Loading data using mvocatalog2mag - Montserrat data');  
	[dnum, mag, subclass, errorflag] = mvocatalog2mag(snum, enum, threshold_mag);  
else   
	event = geteventdata(snum, enum, threshold_mag, region, db, archiveformat);
	[dnum, mag, subclass, errorflag] = event2mag(event);  
end  

if length(dnum)==0
	disp('No data found');
	return;
else
	datafound = 1;
end
     
% sort the date and magnitude data by subclass  
% output are cell arrays of dates and magnitudes corresponding to  
% subclasses in "subclasses_selected" variable  
[cdnum, cmag] = sort_mag(dnum, mag, subclass, subclasses_selected);  

numsubclasses = length(subclasses_selected); 
 
% loop over subclasses_selected 
for i=1:numsubclasses 
     
	% fill data array with appropriate item from parameter cell array 
	dnum = cdnum{i};  
        energy = mag2eng(cmag{i}); 

        % get total counts, energy and magnitude 
        total_magnitude{i} = eng2mag(sum(energy)); 
        total_counts{i} = length(dnum) 
     
	% if no data, don't do anything more 
	if total_counts{i} > 0 
        
		% bin the counts/magnitude data  
		if binsize > 0
			[tempdnum, tempcts, tempenergy, tempsmallest] = bin_irregular(dnum, energy, binsize, snum-binsize/2, enum+binsize/2);
			cdnum{i} = tempdnum; ccts{i} = tempcts; ceng{i} = tempenergy;
			tempmag = eng2mag(tempenergy); 
	
			% now just in case, for plotting reasons, replace -Inf with -9.99 for magnitude
			tempmag(find(isinf(tempmag))) = NaN; 
			cmag{i} = tempmag;
		
		end
	end
end

print_debug(sprintf('< %s',mfilename),2); 

  
  
  
  
