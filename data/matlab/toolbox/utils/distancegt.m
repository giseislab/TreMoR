function r=distancegt(C1,C2) 
% Author: Glenn Thompson 2001
% gives great circle distance between two [long,lat,height] coords in metres
% assuming a spherical earth of radius 6378 km
%
% Usage:
%   r=distancegt(C1,C2)
%
% INPUTS:
%   c1        - [longitude,latitude,height] vector for coordinate 1 - or a matrix of lon,lat,height columns
%   c2        - [longitude,latitude,height] vector for coordinate 2
%   NB: longitude & latitude in degrees, height in metres above sea level
%
% OUTPUTS:
%   r         - distance between c1 & c2 in metres 
%
% EXAMPLE:
%   r=distance([0,52.75,0],[-150,64.9,0])
% r =
% 8.3761e+006
% i.e. 8376 km, is the approximate distance between Nottingham & Fairbanks,
% along a great circle

R_aver = 6374000;
deg2rad = pi/180;
lat1 = C1(:,2) * deg2rad;
lon1 = C1(:,1) * deg2rad;
lat2 = C2(2) * deg2rad;
lon2 = C2(1) * deg2rad;
raddiff = acos(cos(lat1).*cos(lat2).*cos(lon1-lon2) + sin(lat1).*sin(lat2));
heightdiff = C1(:,3) - C2(3);
r = sqrt( (R_aver * raddiff ).^2  +  heightdiff.^2);
%
