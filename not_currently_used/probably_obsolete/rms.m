function r=rms(y)
l=length(y)-sum(isnan(y));
r=sqrt(nansum(y.^2)/(l-1));