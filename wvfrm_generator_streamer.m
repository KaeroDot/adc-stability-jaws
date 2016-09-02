clear all
close all

% ------------------ settings ------------------ %<<<1

% clock frequency (frequency of samples of the BPG):
fclock = 13.76256e9
% number of periods in every amplitude section:
P = 10;
% points in memory sections (number of points per frequency section):
% (sum should be <= memory of the BPG):
% (lcm(4, 10, 128) = 640, where 4 amplitudes, 10 periods per amp. section, 128 is word in BPG)
M = 640 .* 11200 .* [16 8 4 2]; 
% amplitudes of the signal:
A = [0.1, 0.3, 0.5, 0.7];
% bit multiplication:
B = 32;
% ADC sampling frequency:
adc.fs = 480e3;

% ------------------ preparation ------------------ %<<<1
% number of amplitude sections in frequency section:
K = length(A);
% number of frequency/memory sections:
L = length(M);
% signal frequencies in every frequency section:
f = fclock ./ M .* (P .* K);

% variable containing waveform:
y = [];
% variable containing ADC samples:
yadc = [];

% ------------------ waveform construction ------------------ %<<<1
% for every frequency/memory section:
for i = 1:L
    % counter vector for one period of sine wave in current amplitude section:
    % (no bit multiplication here)
    cnt = [1 : M(i) ./ (P .* K)];
        % for every amplitude:
        for curA = A
            % BPG samples %<<<2
            % generate samples for one period of signal in current amplitude section:
            tmpy = curA .* sin(2 .* pi .* cnt .* f(i) ./ fclock);
            % repeat to get required number of periods in current amplitude section:
            y = [y repmat(tmpy, 1, P)];

            % ADC samples %<<<2
            % time of ADC samples for whole current amplitude section:
            tadc = [0 : 1./adc.fs : P ./ f(i) .* B ]; 
            tadc = tadc(1:end-1);
            tmpyadc = curA .* sin(2 .* pi .* tadc .* f(i) ./ B);
            yadc = [yadc tmpyadc];
        end % K amplitudes
end % L frequencies

% ------------------ saving the ADC data ------------------ %<<<1
adc.offset = mean(yadc);
yadcint = yadc - adc.offset;
adc.gain = max(yadcint)/double(intmax('int32'));
yadcint = yadcint./adc.gain;

fn = 'simulated_data.bin';
fid = fopen(fn, 'w');
% number of metawaveform periods:
mwperiods = 4000;
% convert to int32:
yadcint = int32(yadcint);
for i = 1:mwperiods
        fwrite(fid, yadcint, 'int32', 0, 'ieee-le');
endfor
fclose(fid);

% info file:
infostr = [];
infostr = [infostr infosettext('data format', '32-bit signed integer, little endian')];
infostr = [infostr infosetnumber('data points', sum(y).*mwperiods)];
infostr = [infostr infosetnumber('sample rate', adc.fs)];
infostr = [infostr infosetnumber('data gain', adc.gain)];
infostr = [infostr infosetnumber('data offset', adc.offset)];
infostr = infosetsection('measurement settings', infostr);
infosave(infostr, fn, 'info', true);

% ------------------ plotting BPG samples ------------------ %<<<1

% decimate data by factor of X for faster plotting:
ydec = y(1:1000:end);
ysdec = y(1:1000:end);
plot(ydec, '-', ysdec, 'x')
%%% print -djpg wv-time.jpg

% ------------------ fft of BPG samples ------------------ %<<<1

disp('calculating 50x spectra')
ylarge = repmat(y, 1, 50);
[F, AMP, PH] = ampphspectrum(y, 1, 0);
disp('finished')
plot(F(1:1e4), AMP(1:1e4))
print -djpg wv-spectrum.jpg

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
