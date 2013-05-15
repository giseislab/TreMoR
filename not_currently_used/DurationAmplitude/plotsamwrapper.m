function [fh,ah,samobject]=plotsamwrapper(subnet, station, snum, enum, measure, varargin)
print_debug(sprintf('> %s', mfilename),1);
[panelperstation, yAxisType, fh, downsampleOn, reduceOn, sourcelat, sourcelon] = process_options(varargin, 'panelperstation', true, 'yAxisType', 'linear', 'fh', false, 'downsampleOn', false, 'reduceOn', false, 'sourcelat', 0, 'sourcelon', 0);
samobject=sam();
numstations = length({station.name});
if ~fh
    fh=figure;
end
set(fh, 'Position',[20 20 800 800]);
count = 0;
if panelperstation % Each dataset in a separate panel
    for c=1:numstations
        s = sam(station(c).name, station(c).channel, snum, enum, measure, '1mindata/S_C_M_YYYY.bob');
        if despikeOn
           s = despike(s);
        end
        if downsampleOn
            s = downsample(s);
        end
        if correctOn
            s = correct(s);
        end
        if reduceOn
            s = reduce(s, 'sourcelat', sourcelat, 'sourcelon', sourcelon); % use default for waveType, waveSpeed, f
        end
        if ~isempty(s.dnum)
            count = count + 1;
            samobject(count) = s;
            clear s
        end
    end
    numstations = numel(samobject);
    for c=1:numstations
        [frame1pos, frame2pos] = calculatePanelPositions(numstations, numstations-c+1, 0.95, 0.8, 0.8);
        ah(c) = axes('position',frame1pos);
        plot1mindata(samobject(c), yAxisType, ah(c), 0, 1, 0);
        
        if iscell(measure)
            ylabel(sprintf('%s',samobject(c).measure));
            %suptitle(sprintf('%s-%s',station(samobject(c)),channel(samobject(c))));
        else
           %ylabel(sprintf('%s\n%s',station(samobject(c)),channel(samobject(c)));
            %suptitle(sprintf('%s',measure(samobject(c))));
        end
        if c<numstations
               set(ah(c), 'XTick', [], 'XTickLabel', {});
        end
        %if c~=floor((1+numstations/2)
            %ylabel('');
        %end
    end        
else % All in the same panel
    [frame1pos, frame2pos] = calculatePanelPositions(1, 1, 0.95, 0.75, 0.8);
    ah = axes('position',frame1pos);
    for c=1:length(samobject)
        hold on;
        plot1mindata(samobject(c), yAxisType, ah, 0, 1);
    end
end

linkaxes(ah, 'x');
datetick('x', 'keeplimits');

print_debug(sprintf('< %s', mfilename),1);



    
