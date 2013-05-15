function timewindow_structure()
% TIMEWINDOW_STRUCTURE holds two fields:
%   start - a datenum identifying the start of a timewindow
%   stop - a datenum specifying the end of a timewindow
% Commonly a vector of timewindows is passed around in IceWeb
%
% Example:
%    mytimewindow(1).start = datenum(2009,3,19);
%    mytimewindow(1).stop = datenum(2009,3,23);
%    mytimewindow(2).start = datenum(2009,3,27);
%    mytimewindow(2).stop = datenum(2009,3,28);