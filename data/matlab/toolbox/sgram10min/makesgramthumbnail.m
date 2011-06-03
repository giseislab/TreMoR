function makesgramthumbnail(largefile)
[pathstr, name, ext, vern]=fileparts(largefile);
croppedfile=sprintf('%s/small_%s%s',pathstr, name, ext);
a = imread(largefile);
axes('Position', [0 0 1 1]);
b = a(41:552, 46:436, :);
d = imresize(b, 0.3);
image(d);
imwrite(d, croppedfile, 'png', 'XResolution', 50, 'YResolution', 50);