classdef sam 
    
%
% SAM Seismic Amplitude Measurement class constructor, version 1.0.
%
% SAM is a generic term used here to represent any continuous data
% sampled at a regular time interval (usually 1 minute). Originally 
% designed for loading and plotting RSAM data at the Montserrat Volcano 
% Observatory (MVO), and then similar measurements derived from the VME 
% "ltamon" program and ampengfft and rbuffer2bsam which took Seisan 
% waveform files as input. 
%
% RSAM data are historically stored in "BOB" format, which consists
% of a 4 byte floating number for each minute of the year, for a 
% single station-channel. In version 2.x of IceWeb (TreMoR) various
% new datasets are stored in BOB format, including the maximum, median,
% mean and RMS values of the ground velocity and displacement, as well
% as energy, peak frequency and mean frequency. So this class also
% can be used to load and plot those data. See usage for LOADBOBFILE
% below.
%
% S = SAM() creates an empty correlation object.
%
% S = SAM(dnum, data) creates a SAM object from a vector of datenum's
% and a corresponding vector of data.
%
% S = SAM(sta, chan, snum, enum, measure, datadir) can be used
% to read BOB files and create a SAM object directly.
%
% Methods:
%   RESAMPLE:
%   DETECTTREMOREPISODES:
%   DOWNSAMPLE: (possibly obsolete, use RESAMPLE).
%   PLOT:
%   TOTEXTFILE:
%   PLOTYY:
%   MAKEBOBFILE:
%   LOADBOBFILE:
%   LOADWFMEASTABLE:
%   REDUCE:
%   ENERGY:
%   SAM2WAVEFORM: Convert SAM object into a WAVEFORM object (be careful!)
%   
%
% % ------- DESCRIPTION OF FIELDS IN SAM OBJECT ------------------
%   DNUM:   a vector of MATLAB datenum's
%   DATA:   a vector of data (same size as DNUM)
%   MEASURE:    a string describing the type of data
%   UNITS:  the units of the data, e.g. nm / sec.
%   SCNL:   the scnlobject corresponding to the data.
%   ISREDUCED:  are the data reduced to remove geometrical spreading.
%               (boolean).
%   USE: use this samobject in plots?

% AUTHOR: Glenn Thompson, Montserrat Volcano Observatory
% $Date: 2000-03-20 $
% $Revision: 0 $


    properties(Access = public)
        dnum = [];
        data = [];
        measure = '';
        units = 'unknown';
        scnl = scnlobject();
        isReduced = false;
        use = true;
        distance = [];
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access = public)

        %function self=sam(dnum, data)
        %    self.dnum = dnum;
        %    self.data = data;
        %end
        function self=sam(varargin)
            switch nargin
                case 2, 
                    self.dnum = varargin{1};
                    self.data = varargin{2};
                case 6,
                    self = self.loadbob(varargin{1}, varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});
            end
                
        end

        function self=downsample(self, minutes)
            % Deprecated? use resample instead?
            % downsample to screen resolution, or given number of minutes
            t = self.dnum;
            y = self.data;
            fs = self.Fs;
            samplingIntervalMinutes = 1.0 / (60 * fs)
            if ~exist('minutes', 'var')
                disp('hello')
                choices = [1 2 5 10 30 60 120 240 360 ];
                days = max(t) - min(t)
                choice=max(find(days > choices));
                minutes=choices(choice);
            end
            crunchfactor = round(minutes / samplingIntervalMinutes)
            if isempty(self.measure)
                self.measure = 'mean';
            end
            if crunchfactor > 1
                self = resample(self, self.measure, crunchfactor);
                %[t, y]=downsamplegt(t, y, minutes / samplingIntervalMinutes);
                print_debug(sprintf('Downsampling data by %d', minutes),3)
            end
        end

        function fs = Fs(self)
            l = length(self.dnum);
            s = self.dnum(2:l) - self.dnum(1:l-1);
            fs = 1.0/(median(s)*86400);
        end

        function toTextFile(self, filepath);
           % toTextFile(filepath);
            %
            fout=fopen(filepath, 'w');
            for c=1:length(self.dnum)
                fprintf(fout, '%f\t%s\t%5.3e\n',self.dnum(c),datestr(self.dnum(c),'yyyy-mm-dd HH:MM:SS.FFF'),self.data(c));
            end
            fclose(fout);
        end
        
        function l=length(self)
            l=numel(self);
        end

        function d = snum(self)
            for i=1:numel(self)
                d = min(self(i).dnum);
            end
        end
        
        function d = enum(self)
            for i=1:numel(self)
                d = max(self(i).dnum);
            end
        end        
        
        function s = station(self)
            for i=1:numel(self)
                s{i} = get(self(i).scnl, 'station');
            end
        end 
        
        function c = channel(self)
            for i=1:numel(self)
                c = get(self(i).scnl, 'channel');
            end
        end 
        
        function handlePlot = plot(self, varargin)
            [yaxisType, h, addgrid, addlegend, fillbelow] = process_options(varargin, 'yaxisType', 'linear', 'h', [], 'addgrid', false, 'addlegend', false, 'fillbelow', false);
            handlePlot = plot1mindata(self, yaxisType, h, addgrid, addlegend, fillbelow);
        end

        function plotyy(obj1, obj2, varargin);   
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
        [waveType, waveSpeed, sourcelat, sourcelon, f] = process_options(varargin, 'waveType', 'surface', 'waveSpeed', 2000, 'sourcelat', 0, 'sourcelon', 0, 'f', 2.0);
        if self.isReduced == true
            disp('Data are already reduced');
            return;
	    end
	    switch self.units
            case 'nm'  % Displacement
                % Do computation in cm
                self.data = self.data / 1e7;
                if isempty(self.distance)
                    % get station coordinates in a structure
                    site = db2stationcoordinates(get(self.scnl,'station'), datenum2epoch(self.dnum(1)));
                    if sourcelat==0 && sourcelon==0
                        disp('No source location given. Cannot compute distance')
                        return;
                    else
                        self.distance = distancegt([sourcelon sourcelat 0], [site.longitude site.latitude 0]); % m
                    end
                end
                r = self.distance * 100; % cm
                ws = waveSpeed * 100; % cm/2
                self.measure = sprintf('%sR%s',self.measure(1),self.measure(2:end));
                switch waveType
                    case 'body'
        				self.data = self.data * r; % cm^2
                        self.units = 'cm^2';
                    case 'surface'
                        wavelength = ws / f; % cm
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
                self.measure = sprintf('%sR%s',self.measure(1),self.measure(2:end));
            otherwise
                error(sprintf('Units %s for measure %s not recognised', self.units, self.measure));
            end
	    end

	    function self=energy(self, r)
            channel = get(self.scnl, 'channel');
            e = energy(self.data, r, channel, self.Fs, self.units);
        	self.data = e.data;
        	self.units = e.units;
            self.measure = 'energy';
            self.isReduced = true;
            %self = set(self, 'r', r);
        end
        
        function w=sam2waveform(self)
            w = waveform;
            w = set(w, 'station', get(self.scnl, 'station'));
            w = set(w, 'channel', get(self.scnl, 'channel'));
            w = set(w, 'units', self.units);
            w = set(w, 'data', self.data);
            w = set(w, 'start', self.snum);
            %w = set(w, 'end', self.enum);
            w = set(w, 'freq', 1/ (86400 * (self.dnum(2) - self.dnum(1))));
            w = addfield(w, 'isReduced', self.isReduced);
            w = addfield(w, 'measure', self.measure);
        end
    
        function save2bobfile(self, datadir);
            mkdir(datadir);
            fname =  catpath(datadir, sprintf('%s_%s_%s',get(self.scnl, 'station'), get(self.scnl, 'channel'), self.measure));
            write2bob(self.dnum, self.data, fname);
        end
        
        %function self = resample(self, varargin)
        %    [resampmethod, rate, newFs] = process_options(varargin, 'resampmethod', 'nanmean', 'newFs', 1.0/60);
        %    oldFs = self.Fs;
        %    l = length(self.data);
        %    samplesPerWindow = oldFs / newFs;
        %    if rate > 1
        %        numWindows = floor(l / samplesPerWindow);
         %       d = reshape(self.data(1:samplesPerWindow*numWindows), samplesPerWindow, numWindows);
          %      eval(sprintf('self.data = %s(abs(d), [], 1);', resampmethod));
           %     self.dnum = self.snum : (1/Fs/86400) : self.enum;
           %     l = length(self.data);
           %     self.dnum = self.dnum(1:l);
            %    self.measure = resampmethod;
            %end
        %end
        
        function self = resample(obj, measure, crunchfactor)
            w = obj.sam2waveform;
            w = resample(w, measure(2:end), crunchfactor);
            self = waveform2sam(w);
            self.measure = measure;
        end
        
        function te=detectTremorEpisodes(obj, threshold, threshoff, duration)
            te = tremorepisode();
            d=obj.data;
            l=length(d);
            episodeFound=false;
            episodeIndex = 0;
            for c=1:length(d)
                if ~episodeFound
                    if d(c)>=threshold
                        startIndex=c;
                        episodeFound=true;
                    end
                else
                    if (d(c)<threshoff)
                        stopIndex=c;
                        episodeFound=false;
                        episodeDuration = obj.dnum(stopIndex)-obj.dnum(startIndex);
                        meanlevel = mean(d(startIndex:stopIndex-1));
                        if episodeDuration >= duration          
                            episodeIndex = episodeIndex+1;
                            episodeIndex
                            startIndex
                            stopIndex
                            datestr(obj.dnum(startIndex))
                            datestr(obj.dnum(stopIndex))  
                            
                            te(episodeIndex) = tremorepisode(obj.dnum(startIndex), obj.dnum(stopIndex));
                            fprintf('Episode %d:\n\tStart: %s\n\tEnd: %s\n\tDuration: %.2f hours\n\tMean: %.2f\n',episodeIndex, datestr(obj.dnum(startIndex)), datestr(obj.dnum(stopIndex)), episodeDuration*24, meanlevel);
                        end
                    end
                end
            end
        end
        
                
        
        function self = loadbob(self, sta, chan, snum, enum, measure, filepattern)
        % Purpose:
        %	Loads derived data from a binary file in the BOB RSAM format
        %	The pointer position at which to reading from the binary file is determined timewindow.start. 
        %	Load all the data in the timewindow given. So if timewindow is 12:34:56 to 12:44:56, 
        %	it is the samples at 12:35, ..., 12:44 - i.e. 10 of them.
        %       If the timewindow requested spans a year boundary, it will read from all the binary files.
        %	importBinary is the function that reads the binary file. load1minfile is a wrapper to that. 
        %	
        % Input:
        % 	sta - the station name, used as part of the filename
        %	snum, enum - a Matlab datenum representing the start/end date/time.
        %	measure - a string which identifies the measurement type
        %               - examples include dr, drs, en, tdr, tdrs, tmdr, tmdrs
        %
        % Author:
        % 	Glenn Thompson, MVO/AVO, 2000 - 2009 
            self.scnl = scnlobject(sta, chan);
            self.measure = measure;

            [filepattern, datadir] = basename(filepattern);

            % set start year and month, and end year and month
            [syyy sm]=datevec(snum);
            [eyyy em]=datevec(enum);

            %filebase =  catpath(datadir, sprintf('%s_%s_%s',sta,chan,measure));
            % filepattern is like s_c_m_YYYY.bob or S_YYYY.DAT
            filebase = '';
            for i=1:length(filepattern)
                switch filepattern(i)
                    case 's',
                        %if i == 1
                            filebase = sprintf('%s%s',filebase, lower(sta));
                        %else
                        %    filebase = sprintf('%s%s', filebase, filepattern(i));
                        %end
                    case 'c',
                        filebase = sprintf('%s%s',filebase, lower(chan));
                    case 'm',
                        filebase = sprintf('%s%s',filebase, lower(measure));
                    case 'S',
                        %if i==1
                            filebase = sprintf('%s%s',filebase, sta);
                        %else
                        %    filebase = sprintf('%s%s', filebase, filepattern(i));
                        %end
                    case 'C',
                        filebase = sprintf('%s%s',filebase, chan);
                    case 'M',
                        filebase = sprintf('%s%s',filebase, measure);
                    otherwise,
                        filebase = sprintf('%s%s', filebase, filepattern(i));
                end
            end
    

            % load the data
            for yyyy=syyy:eyyy
    
                % Check year against start year 
                if yyyy~=syyy
                    % if not the first year, start on 1st Jan
                    yrsnum=datenum(yyyy,1,1);
                else
                    yrsnum=snum;
                end
   
                % Check year against end year
                if yyyy~=eyyy
                    % if not the last year, end at 31st Dec
                    yrenum=datenum(yyyy,12,31,23,59,59);
                else
                    yrenum = enum;
                end   
   
                % Set path to data file
                % filepattern is like s_c_m_Y.bob or S_Y.DAT
                infile = filebase;
                index = strfind(upper(infile), 'YYYY');
                switch length(index)
                    case 1,
                        infile(index(1):index(1)+3) = sprintf('%d',yyyy);           
                    case 2,
                        infile(index(1):index(2)-1) = sprintf('%d',yyyy);
                end
                infile = catpath(datadir, infile);
                fprintf('Looking for filenames like: %s\n',infile);
  
                if exist(infile, 'file')
                    disp('file found');
                    % Import the data for this year

                    %[dnum, data, datafound] = import1minfile(infile, yrsnum, yrenum);
                    datapointsperday = 1440;

                    % initialise return variables
                    datafound=0;
                    dnum=[];
                    data=[];


                    [yyyy mm]=datevec(yrsnum);
                    days=365;
                    if mod(yyyy,4)==0
                        days=366;
                    end

                    startsample=ceil((yrsnum-datenum(yyyy,1,1))*datapointsperday);
                    endsample =floor((yrenum-datenum(yyyy,1,1))*datapointsperday);
                    nsamples = endsample - startsample;

                    % now ready to create dnum vector
                    dnum = ceilminute(yrsnum)+(0:nsamples-1)/datapointsperday;

                    if ~exist(infile,'file')	
                        % infile doesn't exist
                        print_debug(['No file ',infile],1)
                        data(1:length(dnum))=NaN;
   
                    else
                        % file found
                        print_debug(sprintf( 'Loading data from %s, position %d to %d of %d', ...
                            infile, startsample,(startsample+nsamples-1),(datapointsperday*days) ),3); 
   
                        %fid=fopen(infile,'r', 'b'); % big-endian for Sun, little-endian for PC
                        fid=fopen(infile,'r', 'l'); % big-endian for Sun, little-endian for PC

                        % Position the pointer
                        offset=(startsample)*4;
                        fseek(fid,offset,'bof');
   
                        % Read the data
                        [data,numlines] = fread(fid, nsamples, 'float32');
                        fclose(fid);
                        datafound=0;
                        print_debug(sprintf('mean of data loaded is %e',nanmean(data)),1);
   
                        % Transpose to give same dimensions as dnum
                        data=data';

                        % Test for Nulls
                        if length(find(data>0)) > 0
                            datafound=1;
                        end	

   
                    end

                    % Now paste together the matrices
                    if datafound
                        self.dnum = catmatrices(dnum, self.dnum);
                        self.data = catmatrices(data, self.data);
                    end
                else
                    disp('file not found');
                end   
            end


            % reset the datafound flag - in case last year was a blank
            if length(find(self.data>0)) > 0
                %self.datafound = 1;
                %self.use = true;
            else
                print_debug(sprintf('%s: No data loaded from file %s',mfilename,infile),1);
            end



            clipOn = 0;
            if clipOn==1
                % clip the data depending on type
                if strfind(lower(measure),'dr')
                    i = find(self.data>500);
                    self.data(i)=NaN;
                end

                if strfind(lower(measure),'isp')
                    i = find(self.data>0.01);
                    self.data(i)=NaN;
                end

                if strfind(lower(measure), 'td')
                    i = find(self.data>0.01);
                    self.data(i)=NaN;
                end

                if strfind(lower(measure),'rsam')
                    i = find(self.data>0.01);
                	self.data(i)=NaN;
                end

                if strfind(measure,'en')
                    i = find(self.data>0.0001);
                    self.data(i)=NaN;
                end
            end

            % eliminate any data outside range asked for
            i = find(self.dnum >= snum & self.dnum <= enum);
            self.dnum = self.dnum(i);
            self.data = self.data(i);

            % measure units
            switch upper(self.measure(1))
                case 'D',self.units = 'nm';
                case 'V',self.units = 'nm/s';
            end
        end

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILE LOAD AND SAVE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%	
    methods(Access = public, Static)

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
  
 
     
    end
end

