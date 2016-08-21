clear all
close all

% ------------------ settings ------------------ %<<<1
data.filenamepart = '../data/34/JAWS22_13_D4#1#2_034_ca0p5_four_tone_rep32';
% plot waveform data of first metaperiod?
data.wvplotfirst = 1;
% plot waveform data of last metaperiod?
data.wvplotlast = 1;
% how many points ignore at the beginning:
data.ignorepoints = 61549;
% after all amplitudes frequency changes...
% list of amplitudes:
wv.listamp = [0.1 0.3 0.5 0.7];
% list of frequencies:
wv.listfr = [150 300 600 1200];
% number of periods in every amplitude and frequency section:
wv.secperiods = 10;
% path to the qwtb:
qwtbpath = '~/qwtb/qwtb';

% ------------------ small variables documentation ------------------ %<<<1
% adc - structure, informations about analogue-to-digital converter
% wv - structure, informations about (meta)waveform
% data - structure, informations about data. contains different data for every metawaveform
% ------------------ basic setup ------------------ %<<<1
% create results directory
data.resdir = [data.filenamepart filesep];
if ~exist(data.resdir, 'dir')
        mkdir(data.resdir);
endif

% add QWTB path:
addpath(qwtbpath);

% automatic detection of supercomputer named "cokl":
[s, o] = system('uname -n');
data.cokl = strcmpi(deblank(o), 'vsmp1');

% ------------------ parse info file ------------------ %<<<1
infostr = infoload([data.filenamepart '.bin']);
measset = infogetsection(infostr, 'measurement settings');

data.format = infogettext(measset, 'data format');
if ~strcmp(data.format, '32-bit signed integer, little endian')
        error('incorrect data format')
endif
% length of data in number of points. must be smaller than digits in realmax (cca 15 digits):
data.points = uint64(infogetnumber(measset, 'data points'));
adc.fs = infogetnumber(measset, 'sample rate');
% sometimes the NI5922 in LabVIEW returns not rounded value: 
adc.fs = round(adc.fs);
adc.gain = infogetnumber(measset, 'data gain');
adc.offset = -1 .* infogetnumber(measset, 'data offset');

% ------------------ pre-calculate ------------------ %<<<1
% frequencies of sections during whole metaperiod:
wv.secfr = repmat(wv.listfr, length(wv.listamp), 1);
wv.secfr = wv.secfr(:)';
% amplitudes of sections during whole metaperiod:
wv.secamp = repmat(wv.listamp, 1, length(wv.listfr));
wv.secamp = wv.secamp(:)';
% number of points in every amplitude and frequency section:
wv.secpoint = wv.secperiods./wv.secfr.*adc.fs;

% calculate starting times of sections of first metawaveform
for i = 1:length(wv.secpoint)
        if i == 1
                previouspos = 0;
        else
                previouspos = sum(wv.secpoint(1:i-1));
        endif
        wv.secstart(i) = previouspos + 1;
        wv.secend(i) = sum(wv.secpoint(1:i));

        idrow = find(wv.listamp == wv.secamp(i));
        idrow = idrow(1);
        idcol = find(wv.listfr == wv.secfr(i));
        idcol = idcol(1);
        wv.sectimestart(i) = (previouspos + 0)./adc.fs;
        wv.sectimestartgrid(idrow, idcol) = wv.sectimestart(i);
endfor
[wv.gridfr, wv.gridamp] = meshgrid(wv.listamp, wv.listfr);

% ------------------ parallel processing of data ------------------ %<<<1
% if not on supercomputer, calculate only part of data: 
if ~data.cokl
        data.points = 960000 + data.ignorepoints + 1;
endif
% create a cell of metawaveform starting positions:
mwstartpos = [data.ignorepoints + 1 : sum(wv.secpoint) : data.points];
% vector of times of starts of metaperiods:
% (first has time == 0)
tvec = (mwstartpos(1:end-1) - data.ignorepoints - 1)./adc.fs;

% saves last id so subfunctions will know some figures should be generated:
data.lastid = length(mwstartpos) - 1;

% create parameter cells:
param.adc = adc;
param.wv = wv;
param.data = data;
param.id = 0;
param.data.startpoint = 0;
param.data.starttime = -1;
paramcell = cell(length(mwstartpos)-1,1);
for i = 1:length(mwstartpos)-1
        param.data.id = i;
        param.data.startpoint = mwstartpos(i);
        param.data.starttime = tvec(i);
        paramcell{i} = param;
endfor

% number of CPU used in calculation, just for easy switching:
if data.cokl
        procno = 50;
else
        procno = 4;
endif

% the calculation itself:
res = parcellfun(procno, @load_metaperiod, paramcell, 'verboselevel', 1);

% methods for testing purposes:
%%%res = cellfun(@load_metaperiod, paramcell);
%%%for i = 1:length(paramcell)
%%%        i
%%%        res(i) = load_metaperiod(paramcell{i});
%%%endfor

% ------------------ save data ------------------ %<<<1
save('-binary', [data.resdir filesep 'proc_data.bin'])

% ------------------ plot concatenated data ------------------ %<<<1
calc_conc_data(res, tvec, wv, adc, data)

% ------------------ finish ------------------ %<<<1
disp('--- finish ---')
disp('points expected:')
data.points
if data.points - mwstartpos(end) > sum(wv.secpoint)
        disp('number of processed points is smaller than number of points in info file. missing data!')
endif