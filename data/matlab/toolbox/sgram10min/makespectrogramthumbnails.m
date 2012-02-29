function makespectrogramthumbnails(tenminspfile)

% figure 1 should be a large spectrogram with traces, cropped nicely. Now remove labels and maximise panels.
removelabels;

% we need a name for the labelless large spectrogram
[tmppath, tmpbase, tmpext] = fileparts(tenminspfile);
tmpfile = sprintf('%s/%s_labelless%s',tmppath,tmpbase,tmpext)

% print large labelless PNG
saveImagefile(tmpfile, 72);

% load then delete temporary file 
I = imread(tmpfile);
delete(tmpfile)

% Resize the image (aspect ratio 16:21 same as 576:756) and convert it to an indexed image with 256 colors
% (Note: we were originally creating 150x96, which is far off the aspect ratio of large spectrograms)
[X,map] = rgb2ind(imresize(I, [126 96]), 256);
thumbnailfile = sprintf('%s/smallest_%s%s',tmppath, tmpbase, tmpext);
imwrite(X,map,thumbnailfile,'PNG'); 
[X,map] = rgb2ind(imresize(I, [147 112]), 256);
thumbnailfile = sprintf('%s/smaller_%s%s',tmppath, tmpbase, tmpext);
imwrite(X,map,thumbnailfile,'PNG'); 
[X,map] = rgb2ind(imresize(I, [198 151]), 256);
thumbnailfile = sprintf('%s/small_%s%s',tmppath, tmpbase, tmpext);
imwrite(X,map,thumbnailfile,'PNG'); 
close;

% figure 1 - the large spoectrogram without labels, should still be open. Now remove traces.
figure(1);
removetraces;

% Create traceless thumbnails.
% Resize the image (aspect ratio 16:21 same as 576:756) and convert it to an indexed image with 256 colors
% (Note: we were originally creating 150x96, which is far off the aspect ratio of large spectrograms)
[X,map] = rgb2ind(imresize(I, [126 96]), 256);
thumbnailfile = sprintf('%s/smallest2_%s%s',tmppath, tmpbase, tmpext);
imwrite(X,map,thumbnailfile,'PNG'); 
[X,map] = rgb2ind(imresize(I, [147 112]), 256);
thumbnailfile = sprintf('%s/smaller2_%s%s',tmppath, tmpbase, tmpext);
imwrite(X,map,thumbnailfile,'PNG'); 
[X,map] = rgb2ind(imresize(I, [198 151]), 256);
thumbnailfile = sprintf('%s/small2_%s%s',tmppath, tmpbase, tmpext);
imwrite(X,map,thumbnailfile,'PNG'); 
close;


% Create a thumbnail spectrogram
%thumbfile = sprintf('%s/thumb_%s%s',tmppath, tmpbase, tmpext);
%makeThumbnail(thumbfile); % traceless, printed
%makesgramthumbnail(tenminspfile); % traceful, imwritten


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removelabels()

ax=get(gcf, 'Children');
numpanels = length(ax);
h = 2/numpanels;

% Remove all axes, tickmarks, labels, and axis boxes and title from view
for c=1:numpanels
        set(ax(c), 'Visible', 'off')
end

% Maximise trace panels
for c=1:numpanels/2
	idx = numpanels/2 -c +1;
        pos = get(ax(idx), 'position');
        newpos = [0 (c-1)*h+0.75*h 1 h*.25];
        set(ax(idx), 'position', newpos )
end

% Maximise the spectrogram panels
for c=numpanels/2+1:numpanels
        pos = get(ax(c), 'position');
        newpos = [0 (c-1/h-1)*h 1 h*.75];
        set(ax(c), 'position', newpos )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removetraces()

ax=get(gcf, 'Children');
numpanels = length(ax);
h = 2/numpanels;

% Remove all trace panels from view
for c=1:numpanels/2
        grandchildren = get(ax(c), 'Children');
        set(grandchildren, 'Visible', 'off')
end

% Maximise the spectrogram panels
h = 2/numpanels;
for c=numpanels/2+1:numpanels
        pos = get(ax(c), 'position');
	newpos = [0 (c-1/h-1)*h 1 h*.94];
        set(ax(c), 'position', newpos )
end

















