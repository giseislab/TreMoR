function w=waveform_spike(w)
data=get(w,'data');
l=length(data);
n=round(l/1000);
i=round(rand(n,1)*l);
data(i)=rand(length(i),1)*1e10-0.5e10;
w=set(w,'data',data);
