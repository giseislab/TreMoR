function str = camelcase2underscore(str)

%str = firstalgorithm(str);
str = secondalgorithm(str);

function str2 = firstalgorithm(str)
% first algorithm
r = isupper(str);
f = find(r > 0);
if length(f) > 1
	str2 = str;
	for c=2:length(f)  
		str2 = strrep(str2, str(f(c)), sprintf('_%s', str(f(c))));
	end
end

function str2 = secondalgorithm(str)
str2 = strcat(str(1) ,regexprep(str(2:end), '[A-Z]', '_$0') );


