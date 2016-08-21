% calculates all possible information from a metaperiod
function res = calc_metaperiod(ywhole, wv, adc, data)
% for structures wv and adc see load_cut_data.m
res = [];

% plot waveform (only for first and last run, if enabled):
if (data.wvplotfirst && data.id == 1) || (data.wvplotlast && data.id == data.lastid) 
        t = [0:length(ywhole) - 1]./adc.fs + data.starttime;
        figure('visible','off')
        plot(t, ywhole);
        print_cpu_indep([data.resdir filesep 'mwv' num2str(data.id, '%06d')], data.cokl)
endif

% first cut data into pieces according the amplitude/frequency sections:
for i = 1:length(wv.secpoint)
        % cut the sequence:
        y = ywhole(wv.secstart(i):wv.secend(i));
        % plot it:
        if (data.wvplotfirst && data.id == 1) || (data.wvplotlast && data.id == data.lastid) 
                figure('visible','off')
                t = [1:length(y)]./adc.fs + data.starttime + wv.sectimestart(i); %XXX add starttime
                plot(t, y)
                print_cpu_indep([data.resdir filesep() 'mwv' num2str(data.id, '%06d') 'sec' num2str(i, '%02d')], data.cokl)
        endif
        res.S(i).nom_amp = wv.secamp(i);
        res.S(i).nom_fr = wv.secfr(i);
        % ------------------ calc one period ------------------ %<<<1
        CS.verbose = 0;
        % ------------------ PSFE ------------------ %<<<2
        DI.fs.v = adc.fs;
        DI.y.v = y';
        tmpPSFE = qwtb('PSFE', DI, CS);
        % ------------------ SP-FFT ------------------ %<<<2
        tmpFFT = qwtb('SP-FFT', DI, CS);
        % ------------------ FPNLSF ------------------ %<<<2
        DI.fest.v = wv.secfr(i);
        tmpFPNLSF = qwtb('FPNLSF', DI, CS);
        % ------------------ SFDR ------------------ %<<<2
        tmpSFDR = qwtb('SFDR', DI, CS);
        % ------------------ SFDR from FFT ------------------ %<<<2
        % range of FFT: 
        % from 2 to 80times multiple of main freq:
        idmin = 2;
        idmax = find(tmpFFT.f.v > wv.secfr(i)*80);
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
        res.A_FFT(idrow, idcol) = max(tmpFFT.A.v);
        res.A_FPNLSF(idrow, idcol) = tmpFPNLSF.A.v;
        res.ph_PSFE(idrow, idcol) = tmpPSFE.ph.v;
        res.ph_FFT(idrow, idcol) = max(tmpFFT.ph.v);
        res.ph_FPNLSF(idrow, idcol) = tmpFPNLSF.ph.v;
        res.SFDR(idrow, idcol) = tmpSFDR.SFDRdBc.v;
        res.SFDR_FFT(idrow, idcol) = tmpSFDR_FFT;
endfor

endfunction