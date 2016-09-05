% calculates all possible information from a single metawaveform

function res = calc_metawaveform(ymwv, wv, adc, data)
% for structures wv and adc see main.m
res = [];

% plot metawaveform (only for first and last run, if enabled):
if (data.wvplotfirst && data.id == 1) || (data.wvplotlast && data.id == data.lastid) 
        t = [0:length(ymwv) - 1]./adc.fs + data.starttime;
        figure('visible','off')
        plot(t, ymwv, '-x');
        print_cpu_indep([data.plotdir 'mwv-' num2str(data.id, '%06d')], data.cokl)
endif

% first cut data into pieces according the amplitude sections:
for i = 1:length(wv.secpoint)
        % cut the sequence:
        y = ymwv(wv.secstart(i):wv.secend(i));
        % plot waveform (only for first and last run, if enabled):
        if (data.wvplotfirst && data.id == 1) || (data.wvplotlast && data.id == data.lastid) 
                figure('visible','off')
                t = [1:length(y)]./adc.fs + data.starttime + wv.sectimestart(i);
                plot(t, y, '-x')
                xlabel('time (s)')
                ylabel('U (V)')
                print_cpu_indep([data.plotdir 'mwv-' num2str(data.id, '%06d') 'sec' num2str(i, '%02d')], data.cokl)
        endif
        res.S(i).nom_amp = wv.secamp(i);
        res.S(i).nom_fr = wv.secfr(i);
        % ------------------ calc one period ------------------ %<<<1
        CS.verbose = 0;
        % ------------------ PSFE ------------------ %<<<2
        DI.fs.v = adc.fs;
        DI.y.v = y';
        tmpPSFE = qwtb('PSFE', DI, CS);
        % set phase to -pi +pi
        tmpPSFE.ph.v = wrap_pm_pi(tmpPSFE.ph.v);
        % ------------------ SP-FFT ------------------ %<<<2
        tmpFFT = qwtb('SP-FFT', DI, CS);
        % ------------------ FPNLSF ------------------ %<<<2
        DI.fest.v = wv.secfr(i);
        tmpFPNLSF = qwtb('FPNLSF', DI, CS);
        % wrap phase to -pi +pi
        tmpFPNLSF.ph.v = wrap_pm_pi(tmpFPNLSF.ph.v);
        % ------------------ SFDR ------------------ %<<<2
        tmpSFDR_sinfit = qwtb('SFDR', DI, CS);
        % ------------------ SFDR from FFT ------------------ %<<<2
        % range of FFT: 
        % from 2 to 80times multiple of main freq:
        idmin = 2;
        idmax = find(tmpFFT.f.v > wv.secfr(i)*80);
        % it could happen that wv.secfr(i)*80 is bigger than range of frequencies in the
        % spectrum, so to prevent error:
        if isempty(idmax)
                idmax = length(tmpFFT.f.v);
        endif
        idmax = idmax(1);
        tmp = tmpFFT.A.v(idmin:idmax);
        % highest point:
        highp = max(tmp);
        % remove highest point:
        highpind = find(tmp == highp)(1);
        tmp(highpind) = 0; 
        % get second highest point:
        high2p = max(tmp);
        % calculat sort of SFDR in dBc:
        tmpSFDR_FFT = 20*log10(highp/high2p);
        % ------------------ reformat result to a matrix ------------------ %<<<2
        % amplitude is row, frequency is column
        idcol = find(wv.listfr == res.S(i).nom_fr);
        idcol = idcol(1);
        idrow = find(wv.listamp == res.S(i).nom_amp);
        idrow = idrow(1);
        res.A_PSFE(idrow, idcol) = tmpPSFE.A.v;
        res.A_FPNLSF(idrow, idcol) = tmpFPNLSF.A.v;
        res.f_PSFE(idrow, idcol) = tmpPSFE.f.v;
        res.f_FPNLSF(idrow, idcol) = tmpFPNLSF.f.v;
        res.ph_PSFE(idrow, idcol) = tmpPSFE.ph.v;
        res.ph_FPNLSF(idrow, idcol) = tmpFPNLSF.ph.v;
        res.SFDR_sinfit(idrow, idcol) = tmpSFDR_sinfit.SFDRdBc.v;
        res.SFDR_FFT(idrow, idcol) = tmpSFDR_FFT;

        % for FFT:
        % find the highest peak, wrap phase:
        [tmp, id] = max(tmpFFT.A.v);
        res.f_FFT(idrow, idcol) = tmpFFT.f.v(id);
        res.A_FFT(idrow, idcol) = tmpFFT.A.v(id);
        res.ph_FFT(idrow, idcol) = wrap_pm_pi(tmpFFT.ph.v(id));

endfor

endfunction

function phase_out = wrap_pm_pi(phase); %<<<1
% wraps phase to -pi to +pi
phase_out = phase - 2*pi*floor( (phase+pi)/(2*pi) );
endfunction

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
