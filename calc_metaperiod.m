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
        DI.y.v = y;
        res.S(i).PSFE = qwtb('PSFE', DI, CS);
        % ------------------ SP-FFT ------------------ %<<<2
        res.S(i).FFT = qwtb('SP-FFT', DI, CS);
        % ------------------ reformat result to a matrix ------------------ %<<<2
        % amplitude is row, frequency is column
        idcol = find(wv.frlist == res.S(i).fr_nom);
        idcol = idcol(1);
        idrow = find(wv.amplist == res.S(i).amp_nom);
        idrow = idrow(1);
        res.A_PSFE(idrow, idcol) = res.S(i).PSFE.A.v;
        res.A_FFT(idrow, idcol) = max(res.S(i).FFT.A.v);
endfor

endfunction
