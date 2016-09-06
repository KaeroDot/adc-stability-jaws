clear all
close all

% ------------------ settings ------------------ %<<<1
% filename:
% how many sampled points should be ignored at the beginning:
data.filenamepart = '../../data/34/JAWS22_13_D4#1#2_034_ca0p5_four_tone_rep32';
data.ignorepoints = 61549;
data.filenamepart = '../../data/39/JAWS22_13_D4#1#2_039_ca0p4_four_tone_rep32';
data.ignorepoints = 113579;
data.filenamepart = '../../data/42/JAWS22_13_D4#1#2_042_ca0p5_four_tone_rep32';
data.ignorepoints = 32869;
data.filenamepart = '../../data/48sine/JAWS22_13_D4#2_048_ca0p4_sinus_4.8kHz_rep01';
data.ignorepoints = 47;
%data.filenamepart = '../../data/50sine/JAWS22_13_D4#2_050_ca0p4_sinus_4.8kHz_rep32';
%data.ignorepoints = 2106;
%data.filenamepart = '../../data/simulated_data/simulated_data';
%data.ignorepoints = 239999;
%data.filenamepart = '../../data/simulated_data_noise/simulated_data';
%data.ignorepoints = 239999;
% plot waveform of first metaperiod?
data.wvplotfirst = 1;
% plot waveform of last metaperiod?
data.wvplotlast = 1;
% plot waveform of ignored points?
data.wvplotignored = 1;
% calculate MADEV?
data.madev = 0;
% calculate kendall?
data.kend = 0;
% list of amplitudes in amplitude sections:
wv.listamp = [0.1 0.3 0.5 0.7];
wv.listamp = [0.1];
% list of frequencies in frequency sections:
wv.listfr = [150];
wv.listfr = [150 300 600 1200];
wv.listfr = [150].*32;
% number of periods in every amplitude section:
wv.P = 10;
% path to the qwtb:
qwtbpath = '~/qwtb/qwtb';

% ------------------ small variables documentation ------------------ %<<<1
% adc - structure, informations about analogue-to-digital converter
% wv - structure, informations about metawaveform
% data - structure, informations about sampled data. some fields are different for every metawaveform
% ------------------ basic setup ------------------ %<<<1
% disable saving data on bad exit:
crash_dumps_octave_core(0)
sighup_dumps_octave_core (0)
sigterm_dumps_octave_core (0)

% prevent some QWTB messages:
warning('off','Octave:shadowed-function')

% add QWTB path:
addpath(qwtbpath);

% detection of CMI supercomputer 'cokl':
data.cokl = iscokl;

% if not calculated on cokl, only partial data, mark it in filename:
if data.cokl
        prefix = '';
else
        prefix = 'PARTIAL_';
endif
% create results paths:
[tmpdir tmpname] = fileparts(data.filenamepart);
data.resname = [tmpdir filesep prefix 'result_' tmpname];
data.plotdir = [tmpdir filesep prefix 'result_plots_' tmpname filesep];
% create plot directory if missing:
if ~exist(data.plotdir, 'dir')
        mkdir(data.plotdir);
endif

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
% number of amplitude sections:
wv.K = length(wv.listamp);
% number of frequency sections:
wv.L = length(wv.listfr);
% list of frequencies in amplitude sections during whole metaperiod:
wv.secfr = repmat(wv.listfr, wv.K, 1);
wv.secfr = wv.secfr(:)';
% list of amplitudes in amplitude sections during whole metaperiod:
wv.secamp = repmat(wv.listamp, 1, wv.L);
wv.secamp = wv.secamp(:)';
% number of points sampled by ADC in every amplitude and frequency section:
wv.secpoint = adc.fs ./ wv.secfr .* wv.P ;

% calculate starting times of all sections of in metawaveform
tmp = cumsum(wv.secpoint);
wv.secstart = [0 tmp(1:end-1)] + 1;
wv.secend = tmp;
wv.sectimestart = (wv.secstart - 1) ./ adc.fs;

% generate grids for easier use in calculations:
[wv.gridfr, wv.gridamp] = meshgrid(wv.listamp, wv.listfr);
wv.gridsectimestart = reshape(wv.sectimestart, wv.K, wv.L);

% ------------------ plot ignored points ------------------ %<<<1
% open data file:
fid = fopen([data.filenamepart '.bin'], 'r');
% read ignored points:
[tmp, count] = fread(fid, data.ignorepoints, 'int32', 0, 'ieee-le');
% close file:
fclose(fid);

if (data.wvplotignored)
        figure('visible','off')
        % no time axis, only count for easy readout of point index
        %t = [1:length(tmp)]./adc.fs;
        plot(tmp, '-+')
        %xlabel('time (s)')
        xlabel('points')
        ylabel('U (V)')
        print_cpu_indep([data.plotdir 'ignoredpoints'], data.cokl)
endif

% ------------------ parallel processing of data ------------------ %<<<1
% prepare parameter cell ------------------ %<<<2
% if not on supercomputer, calculate only part of data: 
if ~data.cokl
        data.points = 20*240000 + data.ignorepoints + 1;
endif
% create a cell of metawaveform starting positions:
mwstartpos = [data.ignorepoints + 1 : sum(wv.secpoint) : data.points];
% times of metawaveforms starts:
% (first one has time == 0)
data.tvec = (mwstartpos(1:end-1) - data.ignorepoints - 1)./adc.fs;

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
        param.data.starttime = data.tvec(i);
        paramcell{i} = param;
endfor

% number of CPU used in calculation, just for easy switching:
if data.cokl
        procno = 50;
else
        procno = 4;
endif

% the calculation itself ------------------ %<<<2
disp('starting calculations of metawaveforms')
res = parcellfun(procno, @load_metawaveform, paramcell, 'verboselevel', 1);


% methods for testing purposes:
%%%res = cellfun(@load_waveform, paramcell);
%%%for i = 1:length(paramcell)
%%%        i
%%%        res(i) = load_metawaveform(paramcell{i});
%%%endfor

% ------------------ save data (as safety for the case next calculation is errorneous) ------------------ %<<<1
save('-binary', data.resname);
disp('saved binary data')

% ------------------ calculate concatenated data ------------------ %<<<1
disp('start of concatenated data calculation')
cres = calc_conc_data(res, wv, adc, data);

% ------------------ save data again (with concatenated data) ------------------ %<<<1
save('-binary', data.resname);
disp('saved second binary data')

% ------------------ plot concatenated data ------------------ %<<<1
plot_conc_data(cres, wv, adc, data);

% ------------------ finish ------------------ %<<<1
disp('--- finish ---')
disp('points expected:')
data.points
if data.points - mwstartpos(end) > sum(wv.secpoint)
        disp('number of processed points is smaller than number of points in info file. missing data!')
endif

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
