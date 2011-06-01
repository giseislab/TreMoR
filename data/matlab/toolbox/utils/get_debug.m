function debuglevel=get_debug()
% GET_DEBUG
% get the debug level
%
   try	
    	debuglevel = getpref('runmode', 'debug');
   catch
        debuglevel = 0;
   end

return 
