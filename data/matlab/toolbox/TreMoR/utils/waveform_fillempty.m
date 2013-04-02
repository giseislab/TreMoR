function w = waveform_fillempty(w, snum, enum);
dl = get(w, 'data_length');
% data length is either 30000 (50Hz), 60000 (100Hz), 0 (blank waveform object) or 1 (corrupt waveform object)
idxgood = find(dl~=1);
w = w(idxgood);
idxempty = find(dl==0);
idxfull = find(dl>1);
data = zeros(max(dl), 1);
if ~exist('snum','var')
        [wsnum, wenum]=gettimerange(w(idxfull));
        snum = min(wsnum);
end

for c=1:length(idxempty)
        i = idxempty(c);
        w(i) = set(w(i), 'data', data, 'freq', 100, 'start', snum);
end
