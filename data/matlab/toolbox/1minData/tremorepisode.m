classdef tremorepisode 
    
%
% TREMOREPISODE Tremor episode class constructor, version 1.0.
%
% % ------- DESCRIPTION OF FIELDS IN SAM OBJECT ------------------
%   SNUM:   start date/time in datenum format
%   ENUM:   end date/time in datenum format

% AUTHOR: Glenn Thompson, Montserrat Volcano Observatory
% $Date: 2000-03-20 $
% $Revision: 0 $


    properties(Access = public)
        snum = [];
        enum = [];
        duration = [];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access = public)

        function self=tremorepisode(snum, enum) 
            self.snum = [];
            self.enum = [];
            self.duration = [];
            if exist('snum', 'var')
                self.snum = snum;
            end
            if exist('enum', 'var')
                self.enum = enum;
                self.duration = enum - snum;
            end
        end
        
        function newte=bond(self)
            newcount = 0;
            newte = tremorepisode;
            for count=1:numel(self)
                if count==1
                    newcount = newcount + 1;
                    newte(newcount) = self(count);
                else
                    gap = self(count).snum - self(count-1).enum;
                    fprintf('Episode %d: duration, gap, duration = %.2f %.2f %.2f',count, gap, self(count).duration, self(count-1).duration);  
                    if self(count).duration > gap && self(count-1).duration > gap      
                        fprintf('- BOND\n')
                        % define a new tremorepisode object from
                        % self(count-1).snum to self(count).enum
                        newte(newcount).enum = self(count).enum;
                        newte(newcount).duration = newte(newcount).enum - newte(newcount).snum;
                    else
                        fprintf('\n');
                        % simply copy the old tremorepisode objects
                        newcount = newcount + 1;
                        newte(newcount) = self(count);
                    end
                end
            end    
        end
        
        function handlePlot = plot(self, color)
            ax = axis;
            hold on;
            handlePlot = [];
            for count=1:numel(self)
                    handlePlot(count)=patch([self(count).snum self(count).enum self(count).enum self(count).snum],[ax(3) ax(3) ax(4) ax(4)],color);
                    set(handlePlot(count),'LineStyle','none');
            end
            hold off;
        end
            
    end
end