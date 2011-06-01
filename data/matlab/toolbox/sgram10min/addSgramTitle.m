function addSgramTitle(subnet, timewindow);
titleStr = [subnet,'  ',datestr(timewindow.start,31),' - ',datestr(timewindow.stop,13),' UTC'];
title(titleStr,'Color',[0 0 0],'FontSize',[14], 'FontWeight',['bold']');

