function makesgramthumbnail(largefile)
[pathstr, name, ext, vern]=fileparts(largefile);
croppedfile=sprintf('%s/small_%s%s',pathstr, name, ext);
a = imread(largefile);
axes('Position', [0 0 1 1]);
if strcmp(getenv('HOST'), 'bronco.giseis.alaska.edu')
	b = a(46:659, 57:521, :);
else
	b = a(41:552, 46:436, :); % coho
end
d = imresize(b, 0.3);
image(d);
imwrite(d, croppedfile, 'png', 'XResolution', 50, 'YResolution', 50);
close;

