function h = iceweb_spectrogram_colormap(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
MR=[0,1;
    0.1, 1;
    0.25, 0;
    0.42,0; 
    0.51, 0.5;
    0.52, 0;
    0.58, 0;
    0.68, 1;
    1,1];
MG=[0,1;
    0.1,1;
    0.25, 0;
    0.32, 0;
    0.43, 1;
    0.5, 0.4;
    0.6, 1;
    0.7, 1;
    0.88, 0;
    0.95, 0
    1, 1];

MB=[0,1;
    0.1, 1;
    0.25, 0;
    0.33, 1;
    0.5,1;
    0.52, 0;
    0.78, 0;
    0.88, 0;
    0.95, 1
    1, 1];

h = colormapRGBmatrices(m,MR,MG,MB);

