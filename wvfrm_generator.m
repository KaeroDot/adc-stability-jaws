clear all
close all

% code length (samples in memory of pattern generator):
N = 215040000;
% frequency of samples (the pattern generator):
fclock = 13.76256e9
% number of periods in every amplitude and frequency section.
nCycles = 10;
% length of memory blocks, i.e. number of points per frequency section
% (sum should be <= N):
pointsperfreq = N ./ [2 4 8 16]; 
if sum(pointsperfreq) > N
        error('too many samples!')
end
% signal amplitudes:
amps = [0.1, 0.3, 0.5, 0.7];
% signal frequencies:
freqs = fclock ./ pointsperfreq .* (length(amps) .* nCycles)

% sampling frequency is:
%fs = fclock./sum(pointsperfreq);

y = [];
% construct waveform:
for i = 1:length(pointsperfreq)    
    % current number of points per frequency section:
    currentpoints = pointsperfreq(i); 
    % data vector for each period of current signal frequency section
    data = [1 : fclock ./ freqs(i)]; 
        for currentamp = amps
            % generate samples for current amplitude and frequency
            tmpy = currentamp .* sin(2 .* pi .* data .* freqs(i) ./ fclock);
            % repeat to get required number of periods:
            y = [y repmat(tmpy, 1, nCycles)];
        end % 4 amplitudes
end % 5 frequencies

% decimate data by factor of 10 for faster plotting:
ydec = y(1:1000:end);
plot(ydec)
print -djpg wv-time.jpg

disp('calculating 50x spectra')
ylarge = repmat(y, 1, 50);
[F, AMP, PH] = ampphspectrum(y, 1, 0);
disp('finished')
plot(F(1:1e4), AMP(1:1e4))
print -djpg wv-spectrum.jpg
