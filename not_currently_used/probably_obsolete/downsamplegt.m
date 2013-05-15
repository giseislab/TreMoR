function [dnum,data]=downsamplegt(dnum1,data1,binsize)
%DOWNSAMPLEGT downsample a date and data vector
% Author: Glenn Thompson 2001
% Downsample input data series
%
% Usage:
%   [dnum,data]=downsample(dnum1,data1,binsize)
%
% INPUTS:
%   dnum1       - input date vector in Matlab datenumber format
%   data1       - input data vector
%   binsize     - how many input values to assign to each output value
%
% OUTPUTS:
%   dnum        - output date vector in Matlab datenumber format
%   data        - output data vector
%
% EXAMPLE:
%   [x,y]=downsamplegt(x,y,10);
%   This just downsamples by a factor of 10



% in case these vectors are a different size, indata_length
% is the length of the shortest of them
indata_length=min([length(dnum1) length(data1)]);

% outdata_length is the length of the output data series
outdata_length=floor(indata_length/binsize);

% resample the data using nanmean
for c=1:outdata_length
   i=c*binsize; % index into input data series
   dnum(c)=nanmean(dnum1(i-binsize+1:i)); 
   data(c)=nanmean(data1(i-binsize+1:i));
end

% if there were data omitted from end of input data series, append one more
% sample here
if mod(indata_length,binsize)~=0
   dnum(c+1)=nanmean(dnum1(i+1:indata_length));
   data(c+1)=nanmean(data1(i+1:indata_length));
end
