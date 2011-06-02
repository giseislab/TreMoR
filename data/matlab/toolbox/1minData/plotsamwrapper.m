function [fh,ah,onemin]=plotsamwrapper(subnet, station, snum, enum, measure, varargin)
[panelperstation] = process_options(varargin, 'panelperstation', true);

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

print_debug(sprintf('< %s', mfilename),1);



    
