function h = grayBGR(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
gr = flipud(gray(m));
b = bluehot(m);
r = orangeredpink(m);
g = greenhot(m);

h3 = [gr; b; g; r];

h = h3(1:4:end, :);




