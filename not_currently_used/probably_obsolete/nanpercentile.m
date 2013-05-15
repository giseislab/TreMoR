function m=nanpercentile(x,fraction)
% use prctile instead !
if fraction>1 || fraction<0
    error('fraction should be between 0.0 and 1.0');
end
if size(x,1)>1
    for k=1:size(x,1)
        m(k)=nanpercentile(x(k,:),fraction);
    end
else
    x=sort(x);
    c=length(x);
    while isnan(x(c)) 
        c=c-1;
        if c<1
            m=NaN;
            return;
        end
    end
    mi=round(c*fraction);
    m=x(mi);
end
