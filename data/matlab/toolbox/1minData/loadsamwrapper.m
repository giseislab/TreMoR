function s = loadsamwrapper(subnet, station, snum, enum, measure, varargin)
[despikeOn, downsampleOn, reduceOn, remove_calibs, correctOn, wavetype] = process_options(varargin, 'despikeOn', true, ...
    'downsampleOn', false, 'reduceOn', false, 'remove_calibs', false, 'interactive_mode', false, 'correctOn', false, 'wavetype', 'surface');

global paths 
yaxisType='linear';
if isfield(paths,'ONEMINDATA')
    datadir = paths.ONEMINDATA;
else
    datadir = '1mindata';
end

if reduceOn
    onemin = reduce_displacement(subnet, station, snum, enum, measure, datadir, wavetype);
else
    onemin = stationmeasure2onemin(station, snum, enum, measure, datadir);   
end

% remove zeros
for c=1:length(onemin)
        if onemin(c).datafound % run twice since there may be two pulses per day
            onemin(c).data(find(onemin(c).data<0.03))=NaN;
        end
end

if remove_calibs
    for c=1:length(onemin)
        if onemin(c).datafound % run twice since there may be two pulses per day
            [onemin(c).data]=find_calibration_pulses(onemin(c).dnum, onemin(c).data);
            [onemin(c).data]=find_calibration_pulses(onemin(c).dnum, onemin(c).data);
        end
    end
end

if despikeOn
   for c=1:length(onemin)
        if onemin(c).datafound
            onemin(c).data = despike(onemin(c).data);
        end
   end
end

if downsampleOn
   for c=1:length(onemin)
        if onemin(c).datafound
            [onemin(c).dnum, onemin(c).data] = downsample1min(onemin(c).dnum, onemin(c).data, downsampleOn);
        end
   end
end

if correctOn % corrections all worked out with long sine waves
    for c=1:length(onemin)
        if onemin(c).datafound        
            ref = 0.707; % note that median, rms and std all give same value on x=sin(0:pi/1000:2*pi)
            if strcmp(onemin(c).measure, 'max')
                onemin(c).data = onemin(c).data * ref;
            end
            if strcmp(onemin(c).measure, '68')
                onemin(c).data = onemin(c).data/0.8761 * ref;
            end
            if strcmp(onemin(c).measure, 'mean')
                onemin(c).data = onemin(c).data/0.6363 * ref;
            end 
        end
    end
end

print_debug(sprintf('< %s', mfilename),1);



    
