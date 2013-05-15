function w=waveform_spike(w)
% SPIKE Spike a waveform object so that the despike(w) method can be tested
% 	W = SPIKE(W) where W is a vector of waveform objects will randomly add spikes to the data

% AUTHOR: Glenn Thompson, UAF-GI
% $Date: $
% $Revision: -1 $

for c=1:numel(w)
	data=get(w(c),'data');
	l=length(data);
	n=round(l/1000);
	i=round(rand(n,1)*l);
	data(i)=rand(length(i),1)*1e10-0.5e10;
	w(c)=set(w(c),'data',data);
end
