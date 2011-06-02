function st = db2stationmetadata(sta, chan, datetime)
% station = db2stationmetadata(sta, chan, datetime)
% 
% This returns a structure for a particular station / channel with the
% following fields:
%
% 	station.samprate
%	station.calib
%	station.units
%	station.response
%	station.site.longitude
%	station.site.latitude
%
% It calls the functions DATENUM2EPOCH, GET_RESPONSE and GET_STATION_COORDINATES	
%
% Note: for this function to work the variable paths.DBMASTER must be set
% to the location of your master stations database
%
% Glenn Thompson, 2008-03-28

global PARAMS paths 
print_debug(sprintf('> %s', mfilename),4)

%if ~isfield('paths', 'DBMASTER')
%    paths.DBMASTER = getenv('DBMASTER');
%end

%if ~isfield('PARAMS', 'maxsamprate')
%    PARAMS.maxsamprate=100;
%end

%if ~isfield('PARAMS', 'df')
%    PARAMS.df = 100/1024;
%end
       
%[st.samprate, st.calib, st.units, st.response] = db2response(sta, chan, datetime, PARAMS.df);
%frequencies = 0:PARAMS.df:(PARAMS.maxsamprate/2);
%try
    %sta
    %chan
    %datetime
    %frequencies
    %paths.DBMASTER
    %st.response = response_get_from_db(sta, chan, datetime, frequencies, paths.DBMASTER);
    %st.response(1)
    %st.response(1).scnl
    %st.response.frequencies
    %st.response.values
    %st.response.calib
%catch
    %disp(sprintf('No response for %s-%s',sta,chan));
    %st.response = -1;
%end
st.site = db2stationcoordinates(sta);
        
print_debug(sprintf('< %s', mfilename),4)
