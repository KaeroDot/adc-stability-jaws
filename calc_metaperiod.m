% calculates all possible information from a metaperiod
function res = calc_metaperiod(id, fully, wv, adc, data)
% for structures wv and adc see load_cut_data.m
res = [];

% first cut data into pieces according the amplitude/frequency sections:
for i = 1:length(wv.pointsec)
        % cut the sequence:
        y = fully(wv.posstart(i):wv.posend(i));
        % plot it:
        if data.wvplot
                if id == 1
                        figure('visible','off')
                        plot(y)
                        print_cpu_indep([data.resdir filesep() 'wvpiece' num2str(i, '%05d')], data.cokl)
                endif
        endif
        res.S(i).amp_nom = wv.ampsec(i);
        res.S(i).fr_nom = wv.frsec(i);
        % ------------------ calc one period ------------------ %<<<1
        CS.verbose = 0;
        % ------------------ PSFE ------------------ %<<<2
        DI.fs.v = adc.fs;
        DI.y.v = y';
        res.S(i).PSFE = qwtb('PSFE', DI, CS);
        % ------------------ SP-FFT ------------------ %<<<2
        res.S(i).FFT = qwtb('SP-FFT', DI, CS);
        % ------------------ FPNLSF ------------------ %<<<2
        DI.fest.v = wv.frsec(i);
        res.S(i).FPNLSF = qwtb('FPNLSF', DI, CS);
        % ------------------ SFDR ------------------ %<<<2
        res.S(i).SFDR = qwtb('SFDR', DI, CS);
        % ------------------ SFDR from FFT ------------------ %<<<2
        % range of FFT: 
        % from 2 to 80times multiple of main freq:
        idmin = 2;
        idmax = find(res.S(i).FFT.f.v > wv.frsec(i)*80);
        idmax = idmax(1);
        tmp = res.S(i).FFT.A.v(idmin:idmax);
        % highest point:
        highp = max(tmp);
        % remove highest point:
        highpind = find(tmp == highp)(1);
        tmp(highpind) = 0; 
        % get second highest point:
        high2p = max(tmp);
        % calculat sort of SFDR in dBc:
        res.S(i).SFDR_FFT = 20*log10(highp/high2p);
        % ------------------ reformat result to a matrix ------------------ %<<<2
        % amplitude is row, frequency is column
        idcol = find(wv.frlist == res.S(i).fr_nom);
        idcol = idcol(1);
        idrow = find(wv.amplist == res.S(i).amp_nom);
        idrow = idrow(1);
        res.A_PSFE(idrow, idcol) = res.S(i).PSFE.A.v;
        res.A_FFT(idrow, idcol) = max(res.S(i).FFT.A.v);
        res.A_FPNLSF(idrow, idcol) = res.S(i).FPNLSF.A.v;
        res.SFDR(idrow, idcol) = res.S(i).SFDR.SFDRdBc.v;
        res.SFDR_FFT(idrow, idcol) = res.S(i).SFDR_FFT;
endfor

endfunction
