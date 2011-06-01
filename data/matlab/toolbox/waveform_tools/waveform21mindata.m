function waveform21mindata(w)

print_debug(sprintf('> %s', mfilename),1)

for waveform_num = 1:length(w)

    staname = get(w(waveform_num),'station');
    channel = get(w(waveform_num),'channel');

	print_debug(sprintf('\n#######################\nProcessing %s %s',staname, channel),1)

	% number of samples
	nsamp = length(get(w(waveform_num),'data'));
	nsamp_needed = get(w(waveform_num),'freq') * 60;
	print_debug(sprintf('Number of samples got = %d, (%d required)',nsamp ,nsamp_needed),3)

	% calculate dr & drs
	if (nsamp > nsamp_needed ) % must have at least 1 minute of data

		if strcmp(channel, 'BDF')
            staname = sprintf('%s_%s',staname,channel);
			%disp('This is a pressure sensor. Will not attempt to calculate 1 minute data.');
			%continue
        end
		
		% calculate peak of displacement spectrogram & frequency at which it occurs as well as energy and RSAM
		%try
            spectralMethod = 1;
			[dnum, Vmax, Vmedian, Dmax, Dmedian, Dstd, Energy, smdisp, peakf, meanf, smdispnew ] = compute1mindata(w(waveform_num), spectralMethod);
            
            %figure;
            %subplot(5,1,1), plot(Vmax);
            %subplot(5,1,2), plot(Vmedian);
            %subplot(5,1,3), plot(Dmax);
            %subplot(5,1,4), plot(Dmedian);
            %subplot(5,1,5), plot(Energy);
     
		%%%%% measurements at seismometer %%%%%
            bobOn = 1; wfmeasOn = 0;
            if bobOn
                save2bob(staname, channel, dnum, Vmax,  'Vmax');
                save2bob(staname, channel, dnum, Vmedian, 'Vmedian');
                save2bob(staname, channel, dnum, Dmax, 'Dmax');
                save2bob(staname, channel, dnum, Dmedian, 'Dmedian');
                save2bob(staname, channel, dnum, Energy, 'Energy');
                save2bob(staname, channel, dnum, Energy, 'Energy');           
      
                if spectralMethod
                    save2bob(staname, channel, dnum, smdisp, 'smdisp');
                    save2bob(staname, channel, dnum, peakf, 'peakf');     
                    save2bob(staname, channel, dnum, meanf, 'meanf');
                    save2bob(staname, channel, dnum, smdispnew, 'smdispnew');  
                end
            end
            
            if wfmeasOn
                save2wfmeas(staname, channel, dnum, Vmax, 'Vmax','nm/s');
                save2wfmeas(staname, channel, dnum, Vmedian, 'Vmedian', 'nm/s');
                save2wfmeas(staname, channel, dnum, Dmax, 'Dmax', 'nm');
                save2wfmeas(staname, channel, dnum, Dmedian, 'Dmedian', 'nm');
                save2wfmeas(staname, channel, dnum, Dstd, 'Dstd', 'nm');          
                save2wfmeas(staname, channel, dnum, Energy, 'Energy', 'um2/s');   
            
                if spectralMethod
                    save2wfmeas(staname, channel, dnum, smdisp, 'smdisp', 'nm');
                    save2wfmeas(staname, channel, dnum, peakf, 'peakf', 'Hz');     
                    save2wfmeas(staname, channel, dnum, meanf, 'meanf', 'Hz');
                    save2wfmeas(staname, channel, dnum, smdispnew, 'smdispnew', 'nm');               
                end
            end

		%catch
		%	disp(sprintf('Could not compute derived data for %s',staname));
		%end

	end
end
print_debug(sprintf('< %s', mfilename),1)

