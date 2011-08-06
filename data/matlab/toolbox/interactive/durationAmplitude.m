function lambda=durationAmplitude(samobject, law)
%lambda=durationAmplitude(samobject, law)
measure=samobject(1).measure;
sta=station(samobject);
%chan=channel(samobject);

% colours to plot each station
lineColour={[0 0 1];[1 0 0];[0 1 0];[0 0 0];[.4 .4 0];[0 .4 0 ];[.4 0 0];[0 0 .4];[0.5 0.5 0.5];[0.25 .25 .25]};
%xmin=0; xmax=4; % cm^2
interval = 0.05;

% remove datasets marked for use==false
use = [samobject.use];
samobject = samobject(find(use == true));


for c=1:numel(samobject)
    figure;
    disp(sprintf('Processing station %s',sta{c})) 

	% bin the data in 0.05 cm^2 bins
	m = max(samobject(c).data);
	threshold = 0.0:interval:m;
	minutes=[];
	for d = 1:length(threshold)
		i = find(samobject(c).data > threshold(d));
		minutes(d) = length(i);
	end

	% define x and y
	totalMinutes = length(samobject(c).data);
	switch law
        case {'exponential'}
            x = threshold;
            xlabelstr = samobject(c).measure;
        case {'power'}
            x = log10(threshold);
            xlabelstr = sprintf('log10(%s)',samobject(c).measure);
        otherwise
            error('law unknown')
    end
	y=log10(minutes/totalMinutes);

	% plot circles
    figure
	plot(x,y,'o', 'Color', lineColour{c});
    xlabel(xlabelstr);
    ylabel('log10(fractional duration)');
	hold on;
	%set(gca,'XLim',[xmin xmax]);

    
    lambda{c}=0;
    r2{c}=0;
    
	% user select a range of data
    disp('Left-click Select lowest X, any other mouse button to ignore this station')
	[x1, y1, button1]=ginput(1);
    if button1==1
        disp('Left-click Select highest X, any other mouse button to ignore this station')
        [x2, y2, button2]=ginput(1);    
        if button2==1
            if x2>x1
               % draw a dotted line to show where user selected	
            	plot([x1 x2], [y1 y2], '-.', 'Color', lineColour{c});

            	% select requested data range and do a least squares fit
            	ii = find(x >= x1 & x <= x2);
            	wx = x(ii);
            	wy = y(ii);
            	[p{c},S{c}]=polyfit(wx,wy,1);
                output = polyval(p{c},wx);
            	correlation = corrcoef(wy, output);
            	r2{c} = correlation(1,2);

            	% compute lambda
            	p0=p{c};
                switch law
                    case {'exponential'}
                        lambda{c} = -p0(1)/log10(exp(1));
                    case {'power'}
                        lambda{c} = -p0(1); 
                    otherwise
                        error('law unknown')
                end
            	 
            	disp(sprintf('\characteristic D_R_S=%.2f cm^2, R^2=%.2f',lambda{c},r2{c}));

            	% draw the fitted line
            	xf = [min(wx) max(wx)];
            	yf = xf * p0(1) + p0(2);
            	plot(xf, yf,'-','Color', lineColour{c});
                
                %ylabel('log10(t/t0)');
                %xlabel(sprintf('D_R_S (%s) (cm^2)',measure));

                title(sprintf('Duration-Amplitude from %s to %s',datestr(samobject(c).snum,31),datestr(samobject(c).enum,31)));

                % Add legend
                yrange=get(gca,'YLim');
                xlim = get(gca,'XLim');
                xmax=max(xlim);

                xpos = xmax*0.65;
                ypos = (yrange(1)-yrange(2))*0.8;
                lstr = sprintf('%.2f R^2=%.2f',lambda{c},r2{c});
                tstr = [ sta{c}, ' ',lstr];
                text(xpos, ypos, tstr,'Color',lineColour{c}, ...
                    'FontName','Helvetica','FontSize',[14],'FontWeight','bold');


            end
        end
    end
             
end	 


function a=dealgt(s, f)
for c=1:length(s)
        a(c)=getfield(s(c),f);
end
