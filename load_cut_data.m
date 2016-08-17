clear all
close all

% ------------------ settings ------------------ %<<<1
filenamepart = '../data/34/JAWS22_13_D4#1#2_034_ca0p5_four_tone_rep32';
% plot waveform data of first metaperiod?
data.wvplot = 1;
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
data.resdir = [filenamepart filesep];
if ~exist(data.resdir, 'dir')
        mkdir(data.resdir);
endif

% add qwtb path:
addpath(qwtbpath);

if data.cokl
        %graphics_toolkit('gnuplot')
        %% set environment value of GNUTERM
        %terminal = getenv ("GNUTERM")
        %setenv ("GNUTERM", "postscript")
endif

% ------------------ parse info file ------------------ %<<<1
infostr = infoload([filenamepart '.bin']);
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

% ------------------ process data file ------------------ %<<<1
% number of processed points. must be smaller than digits in realmax (cca 15 digits) 
points = uint64(0);
% open file:
fid = fopen([filenamepart '.bin'], 'r');
if ignorepoints > 0
        % read points to ignore:
        [ignored, count] = fread(fid, ignorepoints, 'int32', 0, 'ieee-le');
        points = points + size(ignored,1);
        if data.wvplot
                figure('visible','off')
                plot(ignored)
                print_cpu_indep([data.resdir filesep 'wvignored'], data.cokl)
        endif
endif

% main loop:
res = [];
loopcount = 0;
while points < data.pointl
%%%for ttt = 1:4
        loopcount = loopcount + 1;
        % calculate percentage of processed data:
        % XXX probably this can overflow in t variable for long files:
        per = double(points)./double(data.pointl)*100;
        disp([num2str(per) ' % processed']);
        % calculate timestamp of the first sample of the following metaperiod:
        % (first sample has time == 0)
        % XXX probably this can overflow in t variable for long files:
        t = double(points - ignorepoints)./adc.fs;
        % read points for whole metaperiod:
        [tmp, count] = fread(fid, sum(wv.pointsec), 'int32', 0, 'ieee-le');
        points = points + size(tmp,1);
        % if full metaperiod read:
        if size(tmp,1) == sum(wv.pointsec)
                % get real values:
                tmp = adc.offset + tmp.*adc.gain;
                % plot it:
                if data.wvplot
                        figure('visible','off')
                        plot(tmp);
                        print_cpu_indep([data.resdir filesep 'wv'], data.cokl)
                endif
                % and process data
                res = [res calc_metaperiod(loopcount, t, tmp, wv, adc, data)];
        endif
%%%endfor
endwhile
% close file:
fclose(fid);
% ------------------ save data ------------------ %<<<1
save('-binary', [data.resdir filesep 'proc_data.bin'])

% ------------------ plot concatenated data ------------------ %<<<1
calc_conc_data(res, wv, adc, data)

% ------------------ finish ------------------ %<<<1
disp('--- finish ---')
disp('points read:')
points
disp('points expected:')
data.pointl
if points < data.pointl
        disp('number of points in binary file is smaller than in info file. missing data!')
endif

if data.cokl
        % revert value of GNUTERM:
        %setenv ("GNUTERM", terminal)
endif
