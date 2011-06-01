function [t,y]=downsample1min(t, y, choice)
% downsample to screen resolution
% Would be good to add various options for downsampling
% so that method could be the max, median, or std of a window
% the mean
% either of these methods could be used with non-overlapping windows,
% or with a sliding window - two modes
% the third mode would just be to decimate the data
if choice==1
    clear choice
end
if ~exist('choice','var')
    choices = [2 5 10 30 60 120 240 360 ];
    days = max(t) - min(t);
    choice=max(find(days*2 > choices));
    choice=choices(choice);
end
if ~isempty(choice) 
	[t, y]=downsamplegt(t, y, choice);
	print_debug(sprintf('Downsampling data by %d', choice),3)
end

