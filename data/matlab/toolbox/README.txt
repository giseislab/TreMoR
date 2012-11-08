README
Have created sam. It does not incorporate any "wrapper" level functionality, present in plotoneminwrapper, reduce_displacement or stationmeasure2onemin.
The best approach might be to create a sam_collection object, which can take cell arrays sta, chan, snum, enum, measure and optional arguments like subnet, reduceOn, and then
have this call the sam class for each. Other than a constructor, the only other sam_collection method might be plot. This would do the latter half of plotoneminwrapper.
%
sam also at this time calls some stand-alone functions rather than includes them. But ultimately it should include them, then do away with all references to the onemin structure.
% sam also calls utils/energy. It should be possible to get waveform_computeCumulativeEnergy to call this function also, thereby guaranteeing same results on waveform or sam objects.
% This same approach should also be taken to making other derived measurements like Vmax, Vmean, Vmedian, Dmax, Dmean, Dmedian, Drms, Energy, meanf, peakf. That is there should be an external function call which guarantees the same results from waveform and sam objects.
% The frequency measurements are probably useful outside of this too, so should perhaps be handled through yet a deeper call from derivedMeasurements.
% Perhaps what s needed is a metrics method in sam and waveform. This metrics method would make calls to relevant external function which work only on dnum & data.
%
% Ultimately we also want to reduce swarm parameters to 1 minute (or similar) metrics. With waveform_tools the event catalog could be reduced to energy measurements on triggered waveforms, along with mean_rate and median_rate, and mean magnitude and cumulative magnitude, if magnitude data available. This way, a correlation could be established between magnitudes and energy for both reviewed and unreviewed catalogs.


