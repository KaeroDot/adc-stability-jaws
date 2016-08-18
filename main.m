clear all
close all

% ------------------ settings ------------------ %<<<1
data.filenamepart = '../data/34/JAWS22_13_D4#1#2_034_ca0p5_four_tone_rep32';
% plot waveform data of first metaperiod?
data.wvplot = 0;
% how many points ignore at the beginning:
ignorepoints = 61549;
% after all amplitudes frequency changes...
% list of amplitudes:
wv.amplist = [0.1 0.3 0.5 0.7];
% list of frequencies:
wv.frlist = [150 300 600 1200];
% number of periods in every amplitude and frequency section:
wv.periods = 10;
% path to the qwtb:
qwtbpath = '~/qwtb/qwtb';
% used on supercomputer?
data.cokl = 1;

% ------------------ basic setup ------------------ %<<<1
% create results directory
data.resdir = [data.filenamepart filesep];
if ~exist(data.resdir, 'dir')
        mkdir(data.resdir);
endif

% add QWTB path:
addpath(qwtbpath);

% ------------------ parse info file ------------------ %<<<1
infostr = infoload([data.filenamepart '.bin']);
measset = infogetsection(infostr, 'measurement settings');

data.format = infogettext(measset, 'data format');
if ~strcmp(data.format, '32-bit signed integer, little endian')
        error('incorrect data format')
endif
% length of data in number of points. must be smaller than digits in realmax (cca 15 digits):
data.pointl = uint64(infogetnumber(measset, 'data points'));
adc.fs = infogetnumber(measset, 'sample rate');
% sometimes the NI5922 in LabVIEW returns not rounded value: 
adc.fs = round(adc.fs);
adc.gain = infogetnumber(measset, 'data gain');
adc.offset = -1 .* infogetnumber(measset, 'data offset');

% ------------------ pre-calculate ------------------ %<<<1
% frequency sections during whole metaperiod:
wv.frsec = repmat(wv.frlist, length(wv.amplist), 1);
wv.frsec = wv.frsec(:)';
% amplitude sections during whole metaperiod:
wv.ampsec = repmat(wv.amplist, 1, length(wv.frlist));
wv.ampsec = wv.ampsec(:)';
% number of points in every amplitude and frequency section:
wv.pointsec = wv.periods./wv.frsec.*adc.fs;

% calculate starting times of sections of first metawaveform
for i = 1:length(wv.pointsec)
        if i == 1
                previouspos = 0;
        else
                previouspos = sum(wv.pointsec(1:i-1));
        endif
        wv.posstart(i) = previouspos + 1;
        wv.posend(i) = sum(wv.pointsec(1:i));

        idrow = find(wv.amplist == wv.ampsec(i));
        idrow = idrow(1);
        idcol = find(wv.frlist == wv.frsec(i));
        idcol = idcol(1);
        wv.sectimestart(idrow, idcol) = (previouspos + 0)./adc.fs;
endfor
[wv.frgrid, wv.ampgrid] = meshgrid(wv.amplist, wv.frlist);

% ------------------ parallel processing of data ------------------ %<<<1
% create a cell of data starting positions:
data.pointl = 960000 + ignorepoints + 1;
points = [ignorepoints + 1 : sum(wv.pointsec) : data.pointl];
% vector of times of starts of metaperiods:
% (first has time == 0)
tvec = (points(1:end-1) - ignorepoints - 1)./adc.fs;

% create parameter cells:
param.adc = adc;
param.wv = wv;
param.data = data;
param.id = 0;
param.startpoint = 0;
param.starttime = -1;
paramcell = cell(length(points)-1,1);
for i = 1:length(points)-1
        param.id = i;
        param.startpoint = points(i);
        param.starttime = tvec(i);
        paramcell{i} = param;
endfor

%%%res = cellfun(@load_metaperiod, paramcell);
res = parcellfun(4, @load_metaperiod, paramcell, 'verboselevel', 1);
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
disp('points read:')
points
disp('points expected:')
data.pointl
if points < data.pointl
        disp('number of points in binary file is smaller than in info file. missing data!')
endif
