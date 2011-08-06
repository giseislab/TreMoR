function [fh,ah,samobject]=plotsamwrapper(subnet, station, snum, enum, measure, varargin)
print_debug(sprintf('> %s', mfilename),1);
[panelperstation, yAxisType] = process_options(varargin, 'panelperstation', true, 'yAxisType', 'linear');
samobject=sam();
numstations = length({station.name});
fh=figure;
set(fh, 'Position',[20 20 800 800]);
count = 0;
if panelperstation % Each dataset in a separate panel
    for c=1:numstations
        s = sam(station(c).name, station(c).channel, snum, enum, measure, '1mindata/S_C_M_YYYY.bob');
        if ~isempty(s.dnum)
            count = count + 1;
            samobject(count) = s;
            clear s
        end
    end
    numstations = numel(samobject);
    for c=1:numstations
        [frame1pos, frame2pos] = calculateFramePositions(numstations, numstations-c+1, 0.95, 0.8, 0.8);
        ah(c) = axes('position',frame1pos);
        plot1mindata(samobject(c), yAxisType, ah(c), 0, 1);
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
    [frame1pos, frame2pos] = calculateFramePositions(1, 1, 0.95, 0.75, 0.8);
    ah = axes('position',frame1pos);
    for c=1:length(samobject)
        hold on;
        plot1mindata(samobject(c), yAxisType, ah, 0, 1);
    end
end

linkaxes(ah, 'x');
datetick('x', 'keeplimits');

print_debug(sprintf('< %s', mfilename),1);



    
