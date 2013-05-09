function h = icewebmap2(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
MR = [0 0; 0.2 0; 0.4 1; 0.5 1; 0.6 0; 0.8 0; 1 1];
MG = [0 0; 0.4 0; 0.6 1; 0.8 0; 1 1];
MB = [0 0; 0.2 1; 0.4 0; 0.6 0; 0.8 1; 1 1];
    

h = colormapRGBmatrices(m,MR,MG,MB);

