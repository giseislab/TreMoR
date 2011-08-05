function [fh,ah,samobject]=plotsamwrapper(subnet, station, snum, enum, measure, varargin)
[panelperstation, yAxisType] = process_options(varargin, 'panelperstation', true, 'yAxisType', 'linear');
samobject=[];
numstations = length({station.name});
fh=figure;
set(fh, 'Position',[20 20 800 800]);
count = 0;
if panelperstation % Each dataset in a separate panel
    for c=1:numstations
        [frame1pos, frame2pos] = calculateFramePositions(numstations, numstations-c+1, 0.95, 0.8, 0.8);
        ah(c) = axes('position',frame1pos);
        s = sam(station(c).name, station(c).channel, snum, enum, measure, '1mindata/S_C_M_YYYY.bob');
        if ~isempty(s.dnum)
            count = count + 1;
            samobject(count) = s;
            clear s
            plot1mindata(samobject(count), yAxisType, ah(c), 0, 1);
            if iscell(measure)
                ylabel(sprintf('%s',samobject(count).measure));
                suptitle(sprintf('%s-%s',samobject(count).station.name,samobject(count).station.channel));
            else
                ylabel(sprintf('%s\n%s',samobject(count).station.name,samobject(count).station.channel));
                suptitle(sprintf('%s',samobject(count).measure));
            end
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
datetickgt(snum,enum);

print_debug(sprintf('< %s', mfilename),1);



    
