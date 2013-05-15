function makesgramthumbnail(largefile)
[pathstr, name, ext, vern]=fileparts(largefile);
croppedfile=sprintf('%s/small_%s%s',pathstr, name, ext);
%filedata = dir(largefile);
try
	a = imread(largefile);
catch
	print_debug(sprintf('Could not read image file %s',largefile),0);
	return;
end

axes('Position', [0 0 1 1]);
try
	if strcmp(getenv('HOST'), 'bronco.giseis.alaska.edu')
		b = a(46:659, 57:521, :);
	else
		b = a(41:552, 46:436, :); % coho
	end
catch
	if size(a) == [526 400 3] % This seems to be size manually plotting on bronco
		b = a(31:end-63, 40:end-39, :);
	else
		b = a; % no idea
	end
end
d = imresize(b, [150 96]); % this should match tdimg width and height in style2.css 
%image(d);
%d = downsample2d(d, 3);
%imwrite(d, croppedfile, 'png', 'XResolution', 30, 'YResolution', 30);
imwrite(d, croppedfile, 'png');
close;

function [ Y ] = downsample2d(M, f)
layers = size(M,3); 
if layers>1
	for c=1:layers
		A =  M(:, :, c);
		A = downsample2d(A);
		s = size(A);
		%Y(1:s(1), 1:s(2), c) = A;
	end
else	
	N = downsample(M,f);
	N = N';
	P = downsample(N,f);
	Y = P';
end
