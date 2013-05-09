function generate_spectrogram_colormaps()
close all
%figure(1)
% old colormap (see spectralobject)
showRGBchannels(default_spectralobject_colormap, [60 120]);
print -dpng -r100 -f1 default_spectralobject_colormap.png
% new colormap, 2013/05/08
%figure(2)
showRGBchannels(iceweb_spectrogram_colormap(1024), [35 125]);
print -dpng -r100 -f2 iceweb_spectrogram_colormap.png