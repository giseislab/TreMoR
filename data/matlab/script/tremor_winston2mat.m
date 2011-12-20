function tremor_winston2mat(subnets, tw)
global paths PARAMS
WINSTON_DATASOURCE(1) = datasource('winston', 'churchill.giseis.alaska.edu', 16022);
WINSTON_DATASOURCE(2) = datasource('winston', 'humpy.giseis.alaska.edu', 16022);
WINSTON_DATASOURCE(3) = datasource('winston', 'pubavo1.wr.usgs.gov', 16022);
print_debug(sprintf('> %s',mfilename),1)

%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS
% loop over all subnets
for subnet_num=1:length(subnets)
%  try % try this subnet
	% which subnet?
	subnet = subnets(subnet_num).name;

	% get IceWeb stations
	station = subnets(subnet_num).stations;
    	scnl = station2scnl(station, 'AV');

	% loop over all elements of tw
	for twcount = 1:length(tw.start)
		tic;
		snum = tw.start(twcount);
		enum = tw.stop(twcount);

		% Have we already process this timewindow?
		tenminspfile = getSgram10minName(subnet,enum);
		if strcmp(PARAMS.mode, 'realtime')
			filenameToTry = sprintf('%s_%s.mat',subnet,datestr(snum,30));
			try
				mylist=ls(sprintf('waveform_files/*/%s',filenameToTry));
				% go to next timewindow because the waveform MAT exists somewhere in the processing system
				continue;
			catch
				% waveform MAT file not found
				% need to check for spectrogram file too
				if exist(tenminspfile,'file')
					% if the spectrogram PNG has at least 100000 bytes, it is probably ok
					% less, and it probably had a lot of missing data, or was not created at all
					fileinfo = dir(tenminspfile);
					if (fileinfo.bytes > 100000)
						% go to next timewindow because the spectrogram PNG exists and looks big enough
						continue;	
					end
				else
					% 20111213: Create a zero size spectrogram image, so we know there was an attempt to run IceWeb on this timewindow
					%system(sprintf('touch %s',tenminspfile)); 
				end
			end 
		end

		% Output some information
		disp(sprintf('\n***** Time Window *****'));

		[bname,dname,bnameroot,bnameext] = basename(tenminspfile);
		system(sprintf('mkdir -p %s',dname));
		txtfile = catpath(dname, [bnameroot, '.txt']);
		diary(txtfile);
		disp(sprintf('%s at %s',subnet , datestr(now)));
		disp(sprintf('Start time is %s UTC',datestr(snum)));
		disp(sprintf('End time is %s UTC',datestr(enum)));

		% Get waveform data
		secsRequested = (enum - snum) * 86400;
		secsGot = 0.0;
		minFraction = 0.99;
 		while (secsGot/secsRequested) < minFraction
			w = getwinstonwaveforms(scnl, snum, enum, WINSTON_DATASOURCE);
			if isempty(w)
				disp('No waveform data found');
				break;
			else
				[wsnum, wenum] = gettimerange(w);
				secsGotLastTime = secsGot;
				secsGot = (max(wenum) - min(wsnum)) * 86400;
				if (secsGotLastTime >= secsGot) % quit the loop as doing no better
					fprintf('Still only got %.1f seconds of data - will not wait any longer\n',secsGot);	
					break;
				end
				if (secsGot/secsRequested) < minFraction && strcmp(PARAMS.mode, 'realtime') 
					% Wait up to 5 seconds to get data again
					pauseSecs = max([secsRequested - secsGot 5.0]);
              				print_debug(sprintf('Pausing %.0f seconds for data to catch up', pauseSecs),1);
					pause(pauseSecs); 
				end
			end
		end

		if ~isempty(w)
			for woc=1:numel(w)
				disp(sprintf('waveform %d, stachan %s-%s, samples %d',woc,get(w(woc), 'station'), get(w(woc), 'channel'), length(get(w(woc), 'data')) ));
			end

			% Save waveform data
			save2waveformmat(w, 'waveform_files/stage1_loaded', snum, enum, subnet);

			% update benchmark log
			logbenchmark(mfilename, toc);
		else
			disp('No waveform data from any datasource');
		end

		diary off;

		disp(sprintf('***** Finished %s %s %s *****\n\n', subnet, datestr(snum,15), datestr(enum,15) ));

	end
 % catch
%	disp(sprintf('Failed for subnet %s - probably something wrong with your subnets structure',subnet));
 % end
end
print_debug(sprintf('< %s',mfilename),1)
