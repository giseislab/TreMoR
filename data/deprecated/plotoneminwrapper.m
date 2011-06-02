function [fh,ah,onemin]=plotoneminwrapper(subnet, station, snum, enum, measure, varargin)
[despikeOn, downsampleOn, reduceOn, remove_calibs, interactive_mode, correctOn, wavetype, panelperstation, cumulative] = process_options(varargin, 'despikeOn', true, ...
    'downsampleOn', false, 'reduceOn', false, 'remove_calibs', false, 'interactive_mode', false, 'correctOn', false, 'wavetype', 'surface', 'panelperstation', true, 'cumulative', false);

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


if cumulative
for c=1:length(onemin)
        if onemin(c).datafound 
            onemin(c).data=cumsum(onemin(c).data);
        end
end
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
%despikeOn
%onemin
%onemin.dataoptions.despikeOn = despikeOn;
%onemin.dataoptions.downsampleOn = downsampleOn;
%onemin.dataoptions.reduceOn = reduceOn;
%onemin.dataoptions.remove_calibs = remove_calibs;
%onemin.dataoptions.interactive_mode = interactive_mode;
%onemin.dataoptions.correctOn = correctOn;
%onemin.dataoptions.wavetype = wavetype;
%onemin.dataoptions.panelperstation = panelperstation; % this is a plotting option

% THESE PLOTTING PARTS BELOW SHOULD BE SEPARATED FROM LOADING ABOVE
%
numgraphs = length(onemin);
fh=figure;
set(fh, 'Position',[20 20 800 800]);
if panelperstation % Each dataset in a separate panel
    for c=1:length(onemin)
        [frame1pos, frame2pos] = calculateFramePositions(numgraphs, numgraphs-c+1, 0.95, 0.8, 0.8);
        ah(c) = axes('position',frame1pos);

        plot1mindata(onemin(c), yaxisType, ah(c), 0, 1);
        if iscell(measure)
            ylabel(sprintf('%s',onemin(c).measure));
            suptitle(sprintf('%s-%s',onemin(c).station.name,onemin(c).station.channel));
        else
            ylabel(sprintf('%s\n%s',onemin(c).station.name,onemin(c).station.channel));
            suptitle(sprintf('%s',onemin(c).measure));
        end
        if c<length(station)
               set(ah(c), 'XTick', [], 'XTickLabel', {});
        end
        %if c~=floor((1+length(station))/2)
            %ylabel('');
        %end
    end
else % All in the same panel
    [frame1pos, frame2pos] = calculateFramePositions(1, 1, 0.95, 0.75, 0.8);
    ah = axes('position',frame1pos);
    for c=1:length(onemin)
        hold on;
        plot1mindata(onemin(c), yaxisType, ah, 0, 1);
        %if c<length(station)
        %       set(h, 'XTick', [], 'XTickLabel', {});
        %end
        %if c~=floor((1+length(station))/2)
        %    ylabel('');
        %end
    end
end
datetickgt(snum,enum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


print_debug(sprintf('< %s', mfilename),1);



    
