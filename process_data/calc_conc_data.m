% calculates informations from concatenated data
function cres = calc_conc_data(res, wv, adc, data)
% calibration matrix description:
% indexes:      row          column          sheet
% variable:     amplitude    frequency       time

% structures description:
% res.cal_mat.QUANTITY.METHOD.v - values
% res.cal_mat.QUANTITY.METDHOD.(M)(O)ADEV.tau - tau values
% res.cal_mat.QUANTITY.METDHOD.(M)(O)ADEV.v - (modified)(overlapped) allan deviation values
% res.cal_mat.QUANTITY.METDHOD.corraxislbl - cell of axis labels for correlation matrix plotting
% res.cal_mat.QUANTITY.METDHOD.pears - matrix of pearsons correlation coefficients
% res.cal_mat.QUANTITY.METDHOD.spear - matrix of spearman correlation coefficients
% res.cal_mat.QUANTITY.METDHOD.kend - matrix of kendall correlation coefficients

% ------------------ prepare calibration matrices ------------------ %<<<1
cres.cal_mat.f.PSFE.v = cat(3, res.A_PSFE);
cres.cal_mat.f.FFT.v = cat(3, res.A_FFT);
cres.cal_mat.f.FPNLSF.v = cat(3, res.A_FPNLSF);
cres.cal_mat.A.PSFE.v = cat(3, res.A_PSFE);
cres.cal_mat.A.FFT.v = cat(3, res.A_FFT);
cres.cal_mat.A.FPNLSF.v = cat(3, res.A_FPNLSF);
cres.cal_mat.ph.PSFE.v = cat(3, res.ph_PSFE);
cres.cal_mat.ph.FFT.v = cat(3, res.ph_FFT);
cres.cal_mat.ph.FPNLSF.v = cat(3, res.ph_FPNLSF);
cres.cal_mat.SFDR.sinfit.v = cat(3, res.SFDR_sinfit);
cres.cal_mat.SFDR.FFT.v = cat(3, res.SFDR_FFT);

% ------------------ calculate allan deviations for every calibration point ------------------ %<<<1
count = 0;
% for frequencies:
for l = 1:wv.L
        % for amplitudes:
        for k = 1:wv.K
                count = count + 1;
                t = data.tvec + wv.gridsectimestart(k, l);

                % metawaveform period:
                T = sum(wv.secpoint) ./ adc.fs;

                cres.cal_p(k, l).f.PSFE =            calc_allan(k, l, cres.cal_mat.f.PSFE, T, data);
                cres.cal_p(k, l).f.FFT =             calc_allan(k, l, cres.cal_mat.f.FFT, T, data);
                cres.cal_p(k, l).f.FPNLSF =          calc_allan(k, l, cres.cal_mat.f.FPNLSF, T, data);
                cres.cal_p(k, l).A.PSFE =            calc_allan(k, l, cres.cal_mat.A.PSFE, T, data);
                cres.cal_p(k, l).A.FFT =             calc_allan(k, l, cres.cal_mat.A.FFT, T, data);
                cres.cal_p(k, l).A.FPNLSF =          calc_allan(k, l, cres.cal_mat.A.FPNLSF, T, data);
                cres.cal_p(k, l).ph.PSFE =           calc_allan(k, l, cres.cal_mat.ph.PSFE, T, data);
                cres.cal_p(k, l).ph.FFT =            calc_allan(k, l, cres.cal_mat.ph.FFT, T, data);
                cres.cal_p(k, l).ph.FPNLSF =         calc_allan(k, l, cres.cal_mat.ph.FPNLSF, T, data);
                cres.cal_p(k, l).SFDR.sinfit =       calc_allan(k, l, cres.cal_mat.SFDR.sinfit, T, data);
                cres.cal_p(k, l).SFDR.FFT =          calc_allan(k, l, cres.cal_mat.SFDR.FFT, T, data);
        endfor
endfor

% ------------------ calculate/plot correlation factors ------------------ %<<<1
cres.cal_mat.f.PSFE =            calc_corr(cres.cal_mat.f.PSFE, wv, data);
cres.cal_mat.A.PSFE =            calc_corr(cres.cal_mat.A.PSFE, wv, data);
cres.cal_mat.ph.PSFE =           calc_corr(cres.cal_mat.ph.PSFE, wv, data);
cres.cal_mat.SFDR.sinfit =       calc_corr(cres.cal_mat.SFDR.sinfit, wv, data);

endfunction %>>>1

function cal_p = calc_allan(k, l, cmm, T, data) %<<<1
% k - amplitude section index
% l - frequency section index
% cmm - calibration matrix method (e.g. cal_mat.A.PSFE)
% T - period of metawaveform

        % metawaveform period:
        DI.Ts.v = T; 
        DI.y.v = cmm.v(k, l, :)(:)';
        CS.verbose = 0;
        DO_ADEV = qwtb('ADEV', DI, CS);
        DO_OADEV = qwtb('OADEV', DI, CS);
        if data.madev
                DO_MADEV = qwtb('MADEV', DI, CS);
        endif
        cal_p.ADEV.tau  = DO_ADEV.tau.v;
        cal_p.ADEV.v    = DO_ADEV.adev.v;
        cal_p.OADEV.tau = DO_OADEV.tau.v;
        cal_p.OADEV.v   = DO_OADEV.oadev.v;
        if data.madev
                cal_p.MADEV.tau = DO_MADEV.tau.v;
                cal_p.MADEV.v   = DO_MADEV.madev.v;
        endif
endfunction

function cmm = calc_corr(cmm, wv, data) % %<<<1
% cmm - calibration matrix method (e.g. cal_mat.A.PSFE)

        % prepare matrices and labels:
        mat = [];
        count = 0;
        % for frequencies:
        for l = 1:wv.L
                % for amplitudes:
                for k = 1:wv.K
                        count = count + 1;
                        % create matrix with columns as variables, every row is one observation:
                        mat = [mat cmm.v(k, l, :)(:)];
                        % create labels:
                        cmm.corraxislbl{count} = [num2str(wv.listamp(k)) 'V' num2str(wv.listfr(l)) 'Hz'];
                endfor
        endfor

        % pears correlation %<<<2
        cmm.pears = corr(mat);
        % spearmans correlation %<<<2
        cmm.spear = spearman(mat);
        % kendall correlation %<<<2
        if data.kend
                % takes too much memory, so only if requested:
                cmm.kend = kendall(mat); 
        endif

endfunction

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
