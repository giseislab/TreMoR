function showRGBchannels(Map, decibelsrange)
figure;
ax=axes;
mymap = Map;
x = 0:1/(size(mymap,1)-1):1;
plot(mymap(:,1),x,'r');
hold on;
plot(mymap(:,2),x,'g');
plot(mymap(:,3),x,'b');
plot(mean(mymap,2),x,'ko') 
ylabel('fraction')   
xlabel('intensity') 
set(ax, 'position', [0.08 0.1 0.6 0.85]); 
colormap(mymap);
h=colorbar('EastOutside'); %generate colorbar
cpos=get(h,'position'); %get position of colorbar
set(h,'position',[cpos(1)+0.2 cpos(2:4)]); %shift colorbar
ylabel1 = get(h,'ylabel'); 
set(ylabel1,'fontWeight', 'bold','fontSize', 14, 'String',sprintf('Relative Spectral Power (dB) \n'));
%set(ylabel1,'fontWeight', 'bold','fontSize', 14, 'String',sprintf('Ground Velocity\n'));
ytick = get(h, 'YTick');
dbtick = 10*ceil(decibelsrange(1)/10) : 10 : 10*floor(decibelsrange(2)/10);
indextick = decibels2index(mymap, decibelsrange, dbtick);
set(h, 'YTick', indextick, 'YTickLabel',dbtick);

%dbticks = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150];
%velocityticklabels = {'1 fm/s'; '10 fm/s'; '0.1 pm/s'; '1 pm/s'; '10 pm/s'; '0.1 nm/s'; '1 nm/s'; '10 nm/s'; ...
%    sprintf('0.1 %cm/s', char(181)); sprintf('1 %cm/s',char(181)); sprintf('10 %cm/s',char(181)); ...
%    '0.1 mm/s'; '1 mm/s'; '1 cm/s'; '10 cm/s'; '1 m/s'};
%[sharedVals,idxs] = intersect(dbticks,dbtick);
%vlabels = velocityticklabels(idxs);
%set(h, 'fontSize', 12, 'YTick', indextick, 'YTickLabel',vlabels);
set(get(h, 'xlabel'), 'fontSize', 14, 'fontWeight', 'bold', 'String', sprintf('color scale\nis logarithmic'));

function decibels=index2decibels(mymap,decibelsrange, x)
% mapping from mymap row index to decibels that row represents
decibels=((x-1)/(size(mymap,1)-1)) * (decibelsrange(2) - decibelsrange(1)) + decibelsrange(1);


function index=decibels2index(mymap,decibelsrange, decibels)
% mapping from decibels to mymap row index (not an integer)
index = ((decibels - decibelsrange(1)) / (decibelsrange(2) - decibelsrange(1)) ) * (size(mymap,1) - 1) + 1;

