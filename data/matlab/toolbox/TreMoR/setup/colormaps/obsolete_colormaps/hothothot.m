function h = hothothot(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end

b = bluehot(m);
r = redhot(m);
g = greenhot(m);

h3 = [b; flipud(g); r];

h = h3(1:3:end, :);




