function printfunctionstack(symbol)
st = dbstack;
outstr='';
if numel(st)>1
        for c=numel(st):-1:2
                outstr = sprintf('%s%s%s',outstr, symbol,st(c).name);
        end
end
libgt.print_debug(sprintf('%s at %s',outstr,datestr(libgt.utnow())),1);

