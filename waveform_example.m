scnl(1)=scnlobject('DFR','BDF');
scnl(2)=scnlobject('DFR','EHZ');
scnl(3)=scnlobject('RDJH','BHZ');
scnl(4)=scnlobject('RDN','EHZ');
scnl(5)=scnlobject('RDWB','BHZ');
scnl(6)=scnlobject('RED','EHZ');
scnl(7)=scnlobject('REF','EHZ');
scnl(8)=scnlobject('RSO','EHZ');
ds=datasource('antelope','/aerun/op/run/db/archive_2009/archive_2009_06_06');
snum = 733930.006944;
enum = 733930.013889;
disp(datestr(snum));
disp(datestr(enum));
try 
    w=waveform(ds, scnl, snum, enum);
catch
    disp('something bad happened, but MATLAB did not die!')
end
