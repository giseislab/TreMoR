function h = redorange(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
MR=[0,0; 
    0.3,1;
    1,1];
MG=[0,0;
    0.3,0; 
    0.7,1;
    1,1];
MB=[0,0; 
    1,0];
h = colormapRGBmatrices(m,MR,MG,MB);


