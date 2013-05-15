function w = waveform_quality_check(w, snum, enum)
%WAVEFORM_QUALITY_CHECK Add a quality control structure (qc) to a waveform object
%	Estimate how much good data a waveform object contains
  
% Author: Glenn Thompson, September 2012

% Set global variables which will be used to judge whether data are good or not
MIN_UNIQUE_SAMPLES = 64;
MODE_FRACTION_CHECK_FOR_CLIPPING = 0.1;
MIN_RANGE = 10;

for i=1:numel(w)

        % initialise structure values
	qc.percentage_good = zeros(numel(w),1);
	qc.seconds_expected = (enum-snum)*86400;
        qc.seconds_blank = 0.0;
        qc.seconds_got = 0;
        qc.unique_samples = 0;
        qc.range = NaN;
	qc.bitrange = NaN;
        qc.mode = NaN;
        qc.mode_frequency = NaN;
	qc.mode_fraction = 1.0;
	qc.percentage_good = NaN;

        % get metadata from waveform object
        thissta = get(w(i), 'station');
        thischan = get(w(i), 'channel');
        thisds = get(w(i), 'ds');
        thismode = get(w(i), 'mode');
        thisdl = round(get(w(i), 'data_length'));
        thisfreq = get(w(i), 'freq');

        % update number of seconds of data got
        if ~isnan(thisfreq)
                qc.seconds_got = thisdl/thisfreq;
        end

        if qc.seconds_got > 0
	    % get data
            thisdata = get(w(i),'data');

            % CHECK FOR ONE-SIDED DATA
            [qc.mode, qc.mode_frequency] = mode(thisdata); % only returns NaN if all values NaN
	    if isnan(qc.mode)
		% All data are NaN
                qc.seconds_blank = qc.seconds_got;
	    else
                mode_fraction = (qc.mode_frequency/thisdl); 
                if (mode_fraction > MODE_FRACTION_CHECK_FOR_CLIPPING) % SIGNIFICANT PERCENTAGE OF SAMPLES AT SAME LEVEL (WORRIED ABOUT CLIPPING)
                        if nanmax(thisdata)==qc.mode || nanmin(thisdata)==qc.mode
                                % ONE SIDED DATA - SEISMOMETER STUCK?
                                qc.seconds_blank = qc.seconds_got;
                        end
                end

                % CHECK NUMBER OF UNIQUE VALUES. IF NOT MANY, RADIO GETTING NO SEISMIC SIGNAL?
                qc.unique_samples = length(unique(thisdata));
                if qc.unique_samples<=MIN_UNIQUE_SAMPLES 
                        qc.seconds_blank = qc.seconds_got;
                end

                % CHECK FOR SMALL DATA RANGE - THINK THIS IS OBSOLETE DUE TO UNIQUE VALUE CHECK
                qc.range = max(thisdata) - min(thisdata);
		bitrange = ceil(log(qc.range)/log(2));
                if qc.range<MIN_RANGE % if range < MIN_RANGE, assume all data bad
                       % NOT A MEANINGFUL DATA RANGE - NO SEISMIC SIGNAL?
                       qc.seconds_blank = qc.seconds_got;
                end

                % IF DATA GOOD SO FAR, LET'S SEE HOW MANY MISSING VALUES THERE ARE
                if qc.seconds_blank == 0
                        % MISSING DATA
                        % assume NaN's are missing data
                        theseindices = find(isnan(thisdata));
                        qc.seconds_blank = length(theseindices)/thisfreq;
                end
	    end
	else
		% No data
                qc.seconds_blank = qc.seconds_got;
        end

        % compute the percent of good data
        qc.percentage_good = ((qc.seconds_got-qc.seconds_blank) / qc.seconds_expected) * 100.0;
	
	% Add qc to waveform object
	w(i) = addfield(w(i), 'qc', qc);
end
