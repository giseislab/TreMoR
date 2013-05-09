function h = orangeredpink(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end


h1 = flipud(redorange(m));
h2 = redpink(m);

h = h1(round(m*0.25):round(m*0.75), :);
h = [h ; h2(round(m*0.25):round(m*0.75), :)];

if m < length(h)
    h = h(1:m, :);
end
if m > length(h)
    h = [h; h(end, :)];
end




