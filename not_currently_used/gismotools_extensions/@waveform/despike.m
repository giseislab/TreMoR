function [w] = despike(w);
% DESPIKE Despike a waveform object with matlab_extensions.despike()
% w = despike(w);

% AUTHOR: Glenn Thompson, UAF-GI
% $Date: $
% $Revision: -1 $

for c=1:numel(w)
	y = get(w(c), 'data'); 
	[y, ip] = matlab_extensions.despike( y );
	w(c) = set(w(c), 'data', y);
end

