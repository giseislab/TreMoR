function station_structure()
% Description of a station structure
%   A station structure typically consists of the fields:
%       name - station code, e.g. PV6
%       channel - e.g. EHZ
%       site.latitude
%       site.longitude
%       site.elevation (km)
%       distance (from a volcano summit)
%       response (the response structure from GISMO)
%   Normally vectors of station structures are passed around by IceWeb,
%   e.g.
%	station(1).name = 'PV6';
%	station(1).channel = 'EHZ';
%	station(2).name = 'PVV';
%	station(2).channel = 'EHZ';
%
% There is an obvious overlap here with the scnlobject, and in the longer
% term it would be good to replace station structures with scnlobjects.