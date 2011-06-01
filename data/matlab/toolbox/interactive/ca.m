
choice=menu('duration amplitude plot?:', 'yes', 'no'); 
if choice==1
    load
	gamma=durationAmplitude(subnet, stations, timewindow, measure, onemin, h);
end
