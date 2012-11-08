function reconfigure();
global subnets
print_debug(sprintf('> %s', mfilename),5)
[paths,PARAMS]=pf2PARAMS;
infile = 'params/subnets.d';
fin = fopen(infile,'r');
c=0;
usethissubnet = 0;
while 1,
	tline = fgetl(fin);
	if ~ischar(tline),break,end

	if strfind(tline, 'SUBNET') 
		fields = regexp(tline, '\t', 'split') ;
		usethissubnet = str2num(fields{5});
		if (usethissubnet == 1)
			c = c + 1;
			cc = 0;
			subnets(c).name = fields{2};
        		subnets(c).source.latitude = str2num(fields{3});
        		subnets(c).source.longitude = str2num(fields{4});
			subnets(c).use = str2num(fields{5});
		end

	end
	if strfind(tline, 'scn')
		fields = regexp(tline, '\t', 'split'); 
		cc = cc + 1;
		scn = fields{2};
		scnfields = regexp(scn, '\.', 'split');
	        subnets(c).stations(cc).name = scnfields{1};                   
	        subnets(c).stations(cc).channel = scnfields{2};
	        subnets(c).stations(cc).scnl = scnlobject(scnfields{1}, scnfields{2}, scnfields{3});
	        subnets(c).stations(cc).distance = deg2km(distance(str2num(fields{3}), str2num(fields{4}), subnets(c).source.latitude, subnets(c).source.longitude)); 
	        subnets(c).stations(cc).latitude = str2num(fields{3});
	        subnets(c).stations(cc).longitude = str2num(fields{4});
	        subnets(c).stations(cc).elev = str2num(fields{5});
	        subnets(c).stations(cc).response.calib = str2num(fields{6});
	        subnets(c).stations(cc).use = str2num(fields{7});
	    end
end
fclose(fin)
choice = 0;
while choice~=3,
choice = menu('Main menu', 'Toggle subnets', 'Toggle stations', 'Exit')
switch choice
	case 1, changesubnets();
	case 2, changestations();
end
 
%save pf/tremor_runtime.mat subnets PARAMS paths
%print_debug(sprintf('< %s', mfilename),5)

function changesubnets()
global subnets;
%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[360,500,450,285]);
for c=1:length(subnets)
	uicontrol('Pos',[50 800-c*30 100 25], 'Style', 'text', 'String', subnets(c).name));
	h_cb(c) = uicontrol(fig,'Style','checkbox','Value',subnets(c).use,...
        'String',num2str(subnets(c).use),'tag',sprintf('h_cb%d',c),'Position',[160 800-c*30 100 25],...
        'callback',{@toggle_subnet(c)});
   h_pb(c) = uicontrol('Style','pushbutton','String','Edit',...
          'Position',[250 800-c*30 100 25],...
          'Callback',{@edit_subnet(c)});
end
ha = axes('Units','Pixels','Position',[50,50,200,200]); 
   
% Initialize the GUI.
% Change units to normalized so components resize 
% automatically.
set([f,ha,h_cd, h_pb],...
'Units','normalized');
%Create a plot in the axes.
current_data = [];
plot(1,1);
% Assign the GUI a name to appear in the window title.
set(f,'Name','Spectrogram Config GUI')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');
%  Callbacks. These callbacks automatically
%  have access to component handles and initialized data 
%  because they are nested at a lower level.

  
function toggle_subnet(hObject,eventdata,index) 
global subnets;
subnets(index).use = mod(subnets(index).use + 1,2);

function edit_subnet(hObject,eventdata,index) 
global subnets; 
