function percentagegot = waveform_soh(w, snum, enum)
% Added by Glenn, September 2012
nsecsexpected = (enum-snum)*86400;
percentagegot = zeros(numel(w),1);
for i=1:numel(w)

        % initialise some values
        thisrange = NaN;
        thisnblanksecs = 0.0;
        thism = NaN;
        thisf = NaN;
        thisnsecsgot = 0;
        thisnuniquevalues = 0;
        thisreportstring = '';
        thiserrorstring = '';
	bitrange = NaN;
	mode_fraction = 1.0;
	

        % set stuff from waveform object
        thissta = get(w(i), 'station');
        thischan = get(w(i), 'channel');
        thisds = get(w(i), 'ds');
        thismode = get(w(i), 'mode');
        thisdl = round(get(w(i), 'data_length'));
        thisfreq = get(w(i), 'freq');

        % update number of seconds of data got
        if ~isnan(thisfreq)
                thisnsecsgot = thisdl/thisfreq;
        end

        % the new magic added on 2012/09/25 to discover bad or missing data
        thisreportstring = sprintf('%s SECONDS-GOT:%.1f',thisreportstring, thisnsecsgot);
        if thisnsecsgot > 0
            thisdata = get(w(i),'data');

            % CHECK FOR ONE-SIDED DATA
            [thism, thisf] = mode(thisdata); % only returns NaN if all values NaN
            thisreportstring = sprintf('%s MODE:%.1e MODE-FREQUENCY:%d',thisreportstring, thism, thisf);
	    if isnan(thism)
		% All data are NaN
                thisnblanksecs = thisnsecsgot;
                thiserrorstring = sprintf('%s ALL-NAN',thiserrorstring);
	    else
                mode_fraction = (thisf/thisdl); 
                thisreportstring = sprintf('%s MODE-FRACTION:%.2f',thisreportstring, mode_fraction);
                if (mode_fraction > 0.1) % AT LEAST 10% OF DATA AT SAME LEVEL (WORRIED ABOUT CLIPPING)
                        if nanmax(thisdata)==thism || nanmin(thisdata)==thism
                                % ONE SIDED DATA - SEISMOMETER STUCK?
                                thisnblanksecs = thisnsecsgot;
                                thiserrorstring = sprintf('%s ONE-SIDED',thiserrorstring);
                        end
                end

                % CHECK NUMBER OF UNIQUE VALUES. IF NOT MANY, RADIO GETTING NO SEISMIC SIGNAL?
                thisnuniquevalues = length(unique(thisdata));
                thisreportstring = sprintf('%s UNIQUE-VALUES:%d',thisreportstring, thisnuniquevalues);
                if thisnuniquevalues<=64 % 6 bits of data resolution
                        thisnblanksecs = thisnsecsgot;
                        thiserrorstring = sprintf('%s FEW-UNIQUE',thiserrorstring);
                end

                % CHECK FOR SMALL DATA RANGE - THINK THIS IS OBSOLETE DUE TO UNIQUE VALUE CHECK
                thisrange = max(thisdata) - min(thisdata);
		bitrange = ceil(log(thisrange)/log(2));
                thisreportstring = sprintf('%s BIT-RANGE:%d',thisreportstring, bitrange);
                if thisrange<10 % if range < 10, all data must be bad
                       % NOT A MEANINGFUL DATA RANGE - NO SEISMIC SIGNAL?
                       thisnblanksecs = thisnsecsgot;
                       thiserrorstring = sprintf('%s SMALL-RANGE',thiserrorstring);
                end

                % IF DATA GOOD SO FAR, LETS SEE HOW MANY MISSING VALUES THERE ARE
                if thisnblanksecs == 0
                        % MISSING DATA
                        % assume NaN's are missing data
                        theseindices = find(isnan(thisdata));
                        thisnblanksecs = length(theseindices)/thisfreq;
                        thisreportstring = sprintf('%s MISSING-SECONDS:%.1f',thisreportstring,thisnblanksecs);
                end
	    end
	else
		% No data
                thisnblanksecs = thisnsecsgot;
                thiserrorstring = sprintf('%s NO-DATA',thiserrorstring);
        end
        if strcmp(thiserrorstring,'')
                thiserrorstring = 'GOOD';
        end

        % compute the percent of good data
        percentagegot(i) = ((thisnsecsgot-thisnblanksecs) / nsecsexpected) * 100.0;

        % summarise what we got for this waveform object
        debug.print_debug(sprintf('- waveform %d, stachan %s.%s, got %.1f%%, bitrange %d, mode %f, modefreq %f%%, numuniquevals %d, blank-seconds %f, datasource %s, method %s \n%s \n%s',i,thissta,thischan,percentagegot(i),bitrange,thism,mode_fraction*100.0,thisnuniquevalues,thisnblanksecs,thisds,thismode,thisreportstring,thiserrorstring),2);
end
