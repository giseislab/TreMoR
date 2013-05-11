function h = iceweb_spectrogram_colormap(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
MR=[0,1;
    0.10, 1;
    0.25, 0;
    0.57, 0;
    0.69, 1;
    1,1];
MG=[0,1;
    0.10, 1;
    0.25, 0;
    0.35, 0;
    0.45, 1;
    0.69, 1;
    0.79, 0;
    0.89, 0;
    0.99, 1;
    1.00, 1];

MB=[0,1;
    0.10, 1;
    0.25, 0;
    0.35, 1;
    0.45, 1;
    0.47, 1;
    0.57, 0;
    0.79, 0;
    0.89, 1;
    1.00, 1];

h = colormapRGBmatrices(m,MR,MG,MB);

