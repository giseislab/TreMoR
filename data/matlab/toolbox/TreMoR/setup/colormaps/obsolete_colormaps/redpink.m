function h = redorange(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end

MR=[0,0; 
    0.02,0.3; %this is the important extra point
    0.3,1;
    1,1];
MG=[0,0;
    0.3,0; 
    0.7,1;
    1,1];
MB=[0,0; 
    0.7,0;
    1,1];

h = colormapRGBmatrices(m,MR,MB,MG);


