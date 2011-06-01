classdef sam
    properties(Access = public)
        dnum = [];
        data = [];
        measure = '';
        units = 'unknown';
        scnl = scnlobject();
        isReduced = false;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access = public)

        function self=sam(dnum, data)
            self.dnum = dnum;
            self.data = data;
        end

        function self=downsample(self, minutes)
            % downsample to screen resolution, or given number of minutes
            t = self.dnum;
            y = self.data
	    Fs = computeFs(self);
	    samplingIntervalMinutes = 1.0 / (60 * Fs); 
            if ~exist('minutes', 'var')
                choices = [1 2 5 10 30 60 120 240 360 ];
                days = max(t) - min(t);
                choice=max(find(days > choices));
                minutes=choices(choice);
            end
            if minutes>samplingIntervalMinutes
                [t, y]=downsamplegt(t, y, minutes / samplingIntervalMinutes);
                print_debug(sprintf('Downsampling data by %d', minutes),3)
            end
            self.dnum = t;
            self.data = y;
        end

	function Fs=computeFs(self)
		l = length(self.dnum);a
		s = self.dnum(2:l) - self.dnum(1:l-1);
		Fs = 1.0/(median(s)*86400);
	end

        function toTextFile(self, filepath);
           % toTextFile(filepath);
            %
            fout=fopen(filepath, 'w');
            for c=1:length(self)
                fprintf(fout, '%s\t%5.3e\n',datestr(self.dnum(c),'yyyy-mm-dd HH:MM:SS.FFF'),self.data(c));
            end
            fclose(fout);
        end

        function l=length(self)
            l1=length(self.dnum);
            l2=length(self.data);
            if (l1==l2)
                   l=l1;
            else
                l=-1;
            end
        end

        function plot(self, varargin)
            [yaxisType, h, addgrid, addlegend] = process_options(varargin, 'yaxisType', 'linear', 'h', [], 'addgrid', false, 'addlegend', false);
            plot1mindata(self, yaxisType, h, addgrid, addlegend);
        end

        function plotyy(obj1, obj2, snum, enum, fun1, fun2);   
            [snum, enum, fun1, fun2] = process_options(varargin, 'snum', max([obj1.dnum(1) obj2.dnum(1)]), 'enum', min([obj1.dnum(end) obj2.dnum(end)]), 'fun1', 'plot', 'fun2', 'plot');
            [ax, h1, h2] = plotyy(obj1.dnum, obj1.data, obj2.dnum, obj2.data, fun1, fun2);
            datetick('x');
            set(ax(2), 'XTick', [], 'XTickLabel', {});
            set(ax(1), 'XLim', [snum enum]);
        end

        function self = reduce(self, varargin)
	    % s.reduce('waveType', 'surface|body', 'waveSpeed', 2000);
	    % s.distance and waveSpeed assumed to be in metres (m)
	    % (INPUT) s.data assumed to be in nm or Pa
	    % (OUTPUT) s.data in cm^2 or Pa.m
            [waveType, waveSpeed, outputUnits] = process_options(varargin, 'waveType', 'surface', 'waveSpeed', 2000);
	    if self.isReduced == true
		disp('Data are already reduced');
		return;
	    end
	    switch self.units
		case 'nm'  % Displacement
			   % Do computation in cm
			self.data = self.data / 1e7;
			r = self.distance * 100;
			ws = waveSpeed * 100;
			switch waveType
				case 'body'
        				self.data = self.data * r; % cm^2
					self.units = 'cm^2';
				case 'surface'
					wavelength = surface_wave_speed ./ f;
        				try
            					self.data = self.data .* sqrt(r * wavelength); % cm^2
        				catch
            					print_debug('mean wavelength instead',5)
            					self.data = self.data * sqrt(r * mean(wavelength)); % cm^2            
        				end
					self.units = 'cm^2';
					self.isReduced = true;
				otherwise
					error(sprintf('Wave type %s not recognised'), waveType); 
			end
		case 'Pa'  % Pressure
			   % Do computation in metres
			self.data = self.data * self.distance; % Pa.m	
			self.units = 'Pa m';
			self.isReduced = true;
		else
			error(sprintf('Units %s for measure %s not recognised', self.units, self.measure));
	   	end
	    end

	    function self=energy(self)
		channel = get(self.scnl, 'channel');
		e = energy(self.data, self.distance, channel, self.Fs, self.units);
        	self.data = e.data;
        	self.units = e.units;
		self.measure = 'energy';
		self.isReduced = true;
	    end
	end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILE LOAD AND SAVE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%	
    methods(Access = public, Static)

        function self = loadbobfile(sta, chan, snum, enum, measure, datadir)
	    % could vectorise this function with "if iscell(sta), for s=1:length(sta), station.name = sta{c} etc., then inner loops for chan, measure, [snum enum?]
	    % then would not need wrapper like stationmeasure2onemin.m
 	    % first get it working in scalar mode though
 	    % if I do vectorise this, I should vectorise other functions too. And they might be harder to maintain. Perhaps only IceWeb run-time codes would need it.
            station.name = sta; station.channel = chan;
            onemin = loadbob(station, snum, enum, measure, datadir);
            self.dnum = onemin.dnum;
            self.data = onemin.data;
            self.scnl = scnlobject(onemin.station.name, onemin.station.channel);
            self.measure = onemin.measure;
        end

        function self = loadwfmeastable(sta, chan, snum, enum, measure, datadir)
            station.name = sta; station.channel = chan;
            onemin = loadwfmeas(station, snum, enum, measure, datadir);
            self.dnum = onemin.dnum;
            self.data = onemin.data;
            self.scnl = scnlobject(onemin.station.name, onemin.station.channel);
            self.measure = onemin.measure;
        end

        function makebobfile(outfile, days);
        % makebobfile(outfile, days);
            datapointsperday = 1440;
            samplesperyear = days*datapointsperday;
            a = zeros(samplesperyear,1);
            fid = fopen(outfile,'w');
            fwrite(fid,a,'float32');
            fclose(fid);
        end

	function save2bobfile(self, datadir);
		mkdir(datadir);
		fname =  catpath(datadir, sprintf('%s_%s_%s',get(self.scnl, 'station'), get(self.scnl, 'channel'), self.measure));
		write2bob(dnum, data, fname);
	end     
end		

