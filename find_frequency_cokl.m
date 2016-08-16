function res = find_frequency_cokl(multiplier)

% Script search for clock frequency of JAWS constrained by precision of devices and memory segments
% in pattern generator. Script is very stupid, memory efficient but can take a long time (parfor
% loop is used).

% ---------- SETTINGS  -------------------- 
% target clock frequency (Hz):
targfclock = 14e9;
% search in range around target clock frequency (Hz):
searchrange = 1e9;

% points per memory section of pattern generator
% (each section can contain signal of different frequency)
% (signal frequency is given by points and clock frequency)
pointspersection = 640*11200*[1 2 4 8 16];
pointspersection = 640*multiplier*[1 2 4 8 16];

% code length of memory section containing the fundamental frequency:
fundcodel = pointspersection(end);

% periods per memory section:
% (how many periods is contain in every memory section)
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
allfclock = [minfclock:clockprec:maxfclock];

% initialize result variables:
res_fclock = [];
res_fsig = []; 
res_fcomp = []; 
res_adcfs = {};

% main loop:
parfor i = 1:length(allfclock)
    % current clock frequency:
    curfclock = allfclock(i);
    % calculate current fundamental signal frequency for current clock frequency:
    curfsig = curfclock/fundcodel*periodspersection;
    % calculate current compensation signal frequency for current clock frequency:
    % (compensation signal is generated for whole memory. bit multiplication decreases frequency)
    curfcomp = curfclock/sum(pointspersection)/bitmult;
    % check if compensation signal is possible to generate by compensation clock:
    if fix(curfcomp/compprec) == curfcomp/compprec
        % check if current fundamental signal frequency can be coherently sampled by ADC:
        % (it can be slow calculation for long list of adcfs therefore it is positioned as last condition)
        % (coherency: curfsig/adcfs = periods/samples = rational number,
        % so both periods and samples have to be an integer)
        % periods is known, thus samples must be integer:
        samples = periodsperamp.*adcfs./curfsig;
        cohind = fix(samples) == samples;
        if any(cohind)
            res_fclock = [res_fclock allfclock(i)];
            res_fsig = [res_fsig curfsig];
            res_fcomp = [res_fcomp curfcomp];
            tmp = find(cohind);
            res_adcfs = [res_adcfs {adcfs(tmp)}];
            disp(['found results: ' num2str(length(res_fclock))])
        end
    end
end

% find result nearest to the target clock frequency:
id = find(min(abs(res_fclock - targfclock)) == abs(res_fclock - targfclock));
if isempty(id)
    disp('no result found! increase search range...')
endif
% id = id(1);
% disp('clock frequency (GHz):')
% res_fclock(id)/1e9
% disp('signal fundamental frequency (Hz):');
% res_fsig(id)
% disp(['compensation frequency for ' num2str(bitmult) ' bit multiplication (Hz):']);
% res_fcomp(id)
% disp('ADC sampling frequency (Hz):');
% res_adcfs{id}
res.fclock = res_fclock(id);
res.fsig = res_fsig(id);
res.fcomp = res_fcomp(id);
res.adcfs = res_adcfs{id};

disp('finished')
