% clear all
% close all
% format long

function res = find_frequency2(iterator)

% Script search for clock frequency of JAWS constrained by precision of devices and memory segments
% in pattern generator.

% ---------- SETTINGS  -------------------- 
% target clock frequency (Hz):
targfclock = 13.7e9;
% search in range around target clock frequency (Hz):
searchrange = 0.1e9;

% points per memory section of pattern generator
% (each section can contain signal of different frequency)
% (signal frequency is given by points and clock frequency)
%pointspersection = 640.*11200.*[1 2 4 8 16];
pointspersection = 640.*iterator*[2 4 8 16];

% code length of memory section containing the fundamental frequency:
% (let be fundamental frequency the highest one, i.e. shortest memory section.
% it is supposed that other frequencies are integer multiple of the fundamental one)
fundcodel = min(pointspersection(1));

% periods per memory section:
% (how many periods is contained in every memory section)
periodspersection = 40;
% amplitudes per memory section:
% (how many different amplitudes is contained in every memory section)
amppersection = 4;

% bit multiplication:
% (is required to calculate compensation frequency)
bitmult = 32;

% compensation device precision (Hz):
% following value is for Agilent 33220A:
compprec = 0.000001;
% main clock device precision (Hz):
clockprec = 100;
% list of ADC sampling frequencies (Hz):
% following list is for NI PXI5922:
adcfs = 60e6./[4:1200];
% limit sampling frequencies to ensure 24 bit resolution of NI PXI5922:
adcfs = adcfs(adcfs <= 500e3 & adcfs >= 50e3);

% word length of the pattern generator:
% (data has to be multiple of word length)
wordl = 128;
% ---------- SETTINGS -------------------- 

disp('starting')

if any(fix(pointspersection./wordl) ~= pointspersection/wordl)
    error('one of memory sections not divisible by code length')
end

periodsperamp = periodspersection/amppersection;

if fix(periodsperamp) ~= periodsperamp
    error('periods per amplitude is not an integer! cannot make coherent sampling!')
end

% get range of search:
minfclock = targfclock - searchrange;
maxfclock = targfclock + searchrange;

% generate all possible clock frequencies:
fclock = [minfclock:clockprec:maxfclock];
% calculate fundamental signal frequency:
ffund = fclock./fundcodel.*periodspersection./bitmult;
% calculate compensation signal frequency:
% (compensation signal is generated for whole memory. bit multiplication decreases frequency)
fcomp = fclock./sum(pointspersection)./bitmult;
% check if compensation signal is possible to generate by compensation clock:
id = fix(fcomp./compprec) == fcomp./compprec;
% select only correct results:
fclock = fclock(id);
ffund = ffund(id);
fcomp = fcomp(id);

% initialize result variables:
res.fclock = [];
res.ffund = []; 
res.fcomp = []; 
res.adcfs = {};
res.fsig = {}; 
% through all found clock frequencies:
for i = 1:length(fclock)
    % check if current fundamental signal frequency can be coherently sampled by ADC:
    % (coherency: curffund/adcfs = periods/samples = rational number,
    % so both periods and samples have to be an integer)
    % periods is known, thus samples must be integer:
    samples = periodsperamp.*adcfs./ffund(i);
    cohind = fix(samples) == samples;
    if any(cohind)
        res.fclock = [res.fclock fclock(i)];
        res.ffund = [res.ffund ffund(i)];
        res.fcomp = [res.fcomp fcomp(i)];
        tmp = find(cohind);
        res.adcfs = [res.adcfs {adcfs(tmp)}];
        % calculate all signal frequencies:
        res.fsig = [res.fsig {fclock(i)./pointspersection.*periodspersection./bitmult}];
        disp(['found results: ' num2str(length(res.fclock))])
    end
end

% find result nearest to the target clock frequency:
id = find(min(abs(res.fclock - targfclock)) == abs(res.fclock - targfclock));
if isempty(id)
    disp(['no result found for iterator value ' num2str(iterator) ' ! you can increase search range...'])
    res.fclock = [];
    res.ffund = [];
    res.fsig = [];
    res.fcomp = [];
    res.adcfs = [{}];
else
    id = id(1);
    res.fclock = res.fclock(id);
    res.ffund = res.ffund(id);
    res.fcomp = res.fcomp(id);
    res.adcfs = res.adcfs(id);
    res.fsig = res.fsig(id);
    disp(['results for iterator value ' num2str(iterator) ' :'])
    disp('clock frequency (GHz):')
    res.fclock/1e9
    disp('signal fundamental frequency (Hz):');
    res.ffund
    disp(['compensation frequency for ' num2str(bitmult) ' bit multiplication (Hz):']);
    res.fcomp
    disp('list of ADC sampling frequencies (Hz):');
    res.adcfs
    disp('list of all signal frequencies (Hz):');
    res.fsig
endif

disp('finished')
