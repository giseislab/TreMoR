function y = nanmeanrms(x);
y=sqrt(nanmean(x'.*x'));
