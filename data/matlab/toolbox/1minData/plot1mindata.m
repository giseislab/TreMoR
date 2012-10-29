function handlePlot = plot1mindata(samobject, yaxisType, h, addgrid, addlegend, fillbelow)
% handle = plot1mindata(samobject, yaxisType, h, addgrid, addlegend, fillbelow);
% to change where the legend plots set the global variable legend_ypos
% a positive value will be within the axes, a negative value will be below
% default is -0.2. For within the axes, log(20) is a reasonable value.
% yaxisType is like 'logarithmic' or 'linear'
% h is an axes handle (or an array of axes handles)
% use h = generatePanelHandles(numgraphs)
% Glenn Thompson 1998-2009
%
% % GTHO 2009/10/26 Changed marker size from 5.0 to 1.0
% % GTHO 2009/10/26 Changed legend position to -0.2

%global legend_ypos;
warning off;
print_debug(sprintf('> %s', mfilename),3)

%if isempty(legend_ypos)
	legend_ypos = -0.2;
%end

%set(h);

% set loop sizes
numdatasets = length(samobject);

% colours to plot each station
lineColour={[0 0 0]; [0 0 1]; [1 0 0]; [0 1 0]; [.4 .4 0]; [0 .4 0 ]; [.4 0 0]; [0 0 .4]; [0.5 0.5 0.5]; [0.25 .25 .25]};

% Plot the data graphs
for c = numdatasets:-1:1

	hold on; 
	t = samobject(c).dnum;
	y = samobject(c).data;
	measure = samobject(c).measure;

	print_debug(sprintf('Data length: %d',length(y)),4);

	if strcmp(yaxisType,'logarithmic')==1
		% make a logarithmic plot, with a marker size and add the station name below the x-axis like a legend
		y = log10(y);  % use log plots
		
		handlePlot = plot(t, y, '-', 'Color', lineColour{c}, 'MarkerSize', 1.0);


		if strfind(samobject(c).measure, 'dr')
			%ylabel(sprintf('%s (cm^2)',samobject(c).measure));
			%ylabel(sprintf('D_R (cm^2)',samobject(c).measure));
			Yticks = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 ];
			Ytickmarks = log10(Yticks);
			for count = 1:length(Yticks)
				Yticklabels{count}=num2str(Yticks(count),3);
			end
			set(gca, 'YLim', [min(Ytickmarks) max(Ytickmarks)],'YTick',Ytickmarks,'YTickLabel',Yticklabels);
		end
	else

		% plot on a linear axis, with station name as a y label
		% datetick too, add measure as title, fiddle with the YTick's and add max(y) in top left corner
        if ~fillbelow
            handlePlot = plot(t, y, '-', 'Color', lineColour{c});
        else
            handlePlot = fill([min(t) t max(t)], [min([y 0]) y min([y 0])], lineColour{c});
        end
		%ylabel(samobject(c).measure);


		if c ~= numdatasets
			set(gca,'XTickLabel','');
		end

		yt=get(gca,'YTick');
		ytinterval = (yt(2)-yt(1))/2; 
		yt = yt(1) + ytinterval: ytinterval: yt(end);
		ytl = yt';
        ylim = get(gca, 'YLim');
        set(gca, 'YLim', [0 ylim(2)],'YTick',yt);
        %	set(gca,'YTickLabel',ytl);

    end
    station = get(samobject(c).scnl, 'station');
    channel = get(samobject(c).scnl, 'channel');
    ylabelstr = sprintf('%s.%s %s_{%s} (%s)', station, channel, measure(1), measure(2:end), samobject(c).units)
    ylabel(ylabelstr)
    datetick('x')
    %samobject(c)
    %set(gca, 'YLim', [samobject(c).snum samobject(c).enum])
	%datetickgt(samobject(c).snum, samobject(c).enum);
	if addgrid
		grid on;
	end
	if addlegend && length(y)>0
		xlim = get(gca, 'XLim');
		% getting some error here so trying to catch GT 2009/09/26
%		try
%			legend_ypos = log10(20);
%			legend_ypos = -0.15;
			legend_ypos = 0.9;
%			if legend_ypos > 0
%				legend_xpos = (xlim(2) - xlim(1)) * c/10 + xlim(1);
%			 	text( legend_xpos, legend_ypos, samobject(c).station.name, 'Color', lineColour{c}, ...
%					'FontName', 'Helvetica', 'FontSize', get(get(gca,'XLabel'), 'FontSize'), 'FontWeight', 'bold');
%			else
				legend_xpos = c/10;
			 	%text( legend_xpos, legend_ypos, samobject(c).station.name, 'Color', lineColour{c}, ...
%					'FontName', 'Helvetica', 'FontSize', [14], 'FontWeight', 'bold', 'Units', 'normalized');
%			end
%		catch
			%disp(sprintf('text() command error: legend_xpos = %f, legend_ypos = %f', legend_xpos, legend_ypos))
%		end
		
	end

end

print_debug(sprintf('< %s', mfilename),3)

