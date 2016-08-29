% calculates and plots informations from concatenated data
function calc_conc_data(res, tvec, wv, adc, data)
% ------------------ generate calibration matrices ------------------ %<<<1
% indexes:      row          column          sheet
% variable:     amplitude    frequency       time
cal_mat_A_PSFE = cat(3, res.A_PSFE);
cal_mat_A_FFT = cat(3, res.A_FFT);
cal_mat_A_FPNLSF = cat(3, res.A_FPNLSF);
cal_mat_ph_PSFE = cat(3, res.ph_PSFE);
cal_mat_ph_FFT = cat(3, res.ph_FFT);
cal_mat_ph_FPNLSF = cat(3, res.ph_FPNLSF);
cal_mat_SFDR = cat(3, res.SFDR);
cal_mat_SFDR_FFT = cat(3, res.SFDR_FFT);

% ------------------ plot per method all cal points in one plot ------------------ %<<<1
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_A_PSFE, 'PSFE', wv, data, 'Amplitude', 'A', 'Amplitude (V)');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_A_FFT, 'FFT', wv, data, 'Amplitude', 'A', 'Amplitude (V)');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_A_FPNLSF, 'FPNLSF', wv, data, 'Amplitude', 'A', 'Amplitude (V)');

plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_SFDR, 'sinfit', wv, data, 'Spur. Free Dyn. Ratio', 'SFDR', 'SFDR (dBc)');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_SFDR_FFT, 'FFT', wv, data, 'Spur. Free Dyn. Ratio', 'SFDR', 'SFDR (dBc)');

plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_ph_PSFE, 'PSFE', wv, data, 'Phase', 'ph', 'Phase (rad)');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_ph_FFT, 'FFT', wv, data, 'Phase', 'ph', 'Phase (rad)');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_ph_FPNLSF, 'FPNLSF', wv, data, 'Phase', 'ph', 'Phase (rad)');

% ------------------ plot per calibration point all methods in one plot ------------------ %<<<1
count = 0;
% for frequencies:
for j = 1:size(cal_mat_A_PSFE,2)
        % for amplitudes:
        for i = 1:size(cal_mat_A_PSFE,1)
                count = count + 1;
                t = tvec + wv.sectimestartgrid(i, j);

                % amplitude
                plot_cal_point_all_methods(i, j, count, t, {cal_mat_A_PSFE, cal_mat_A_FFT, cal_mat_A_FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Amplitude', 'A', 'Amp (V)', wv, data, adc);
%               % sfdr
                plot_cal_point_all_methods(i, j, count, t, {cal_mat_SFDR, cal_mat_SFDR_FFT}, {'sine fit', 'FFT'}, 'Spurious Free Dynam. Ratio', 'SFDR', 'SFDR (dBc)', wv, data, adc);
%               % phase %<<<2
                plot_cal_point_all_methods(i, j, count, t, {cal_mat_ph_PSFE, cal_mat_ph_FFT, cal_mat_ph_FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Phase', 'ph', 'ph (rad)', wv, data, adc);

        endfor
endfor

% ------------------ calculate/plot correlation factors ------------------ %<<<1
calc_corr(cal_mat_A_PSFE, 'PSFE', wv, data, 'Amplitude', 'A', 'Amplitude (V)');
calc_corr(cal_mat_ph_PSFE, 'PSFE', wv, data, 'Phase', 'ph', 'Phase (rad)');
calc_corr(cal_mat_ph_PSFE, 'PSFE', wv, data, 'Phase', 'ph', 'Phase (rad)');
calc_corr(cal_mat_SFDR, 'SFDR', wv, data, 'SFDR', 'SFDR', 'SFDR (dBc)');

endfunction %>>>1

function plot_cal_mat_one_method(tvec, sectimestartgrid, cal_mat, methodname, wv, data, varlong, varshort, varaxislbl) % %<<<1
% plots time development for all calibration points for selected method
        plot_types = {'kx-', 'rx-', 'gx-', 'bx-', 'cx-', 'mx-', 'ko-', 'ro-', 'go-', 'bo-', 'co-', 'mo-', 'k*-', 'r*-', 'g*-', 'b*-', 'c*-', 'm*-'};
        count = 0;
        figure('visible','off')
        legendcell = {};
        hold on
        % for frequencies:
        for j = 1:size(cal_mat,2)
                % for amplitudes:
                for i = 1:size(cal_mat,1)
                        count = count + 1;
                        plot(tvec + sectimestartgrid(i, j), cal_mat(i, j, :)(:)' - cal_mat(i, j, 1), plot_types{count})
                        legendcell = [legendcell {['A=' num2str(wv.listamp(i)) ',fr=' num2str(wv.listfr(j))]}];
                endfor
        endfor
        title([ varlong ', time developement, all calibration points, zero is first point a series']);
        xlabel('t (s)');
        ylabel(varaxislbl);
        legend(legendcell);
        legend('location', 'eastoutside');
        print_cpu_indep([data.resdir filesep varshort '_time_' methodname], data.cokl)
        hold off
endfunction

function plot_cal_point_all_methods(ind_amp, ind_fr, count, t, c_cal_mats, c_legends, varlong, varshort, varaxislbl, wv, data, adc) %<<<1
        plot_types = {'k-', 'r-', 'g-', 'b-', 'c-', 'm-'};
        % time %<<<2
        figure('visible','off')
        hold on
        title([varlong ', cal. point: A=' num2str(wv.listamp(ind_amp)) ', f=' num2str(wv.listfr(ind_fr))]);
        for i = 1:length(c_cal_mats)
                plot(t, c_cal_mats{i}(ind_amp, ind_fr, :)(:)', plot_types{i})
        endfor
        xlabel('t (s)');
        ylabel(varaxislbl);
        legend(c_legends);
        legend('location', 'southoutside','orientation','horizontal')
        print_cpu_indep([data.resdir filesep varshort '_time_' num2str(count, '%02d') '-' num2str(ind_amp, '%02d') '-' num2str(ind_fr, '%02d')], data.cokl)
        hold off

        % amplitude, allan %<<<2
        DI.Ts.v = sum(wv.secpoint)./adc.fs;
        DI.y.v = c_cal_mats{1}(ind_amp, ind_fr, :)(:)';
        CS.verbose = 0;
        DO_ADEV = qwtb('ADEV', DI, CS);
        DO_OADEV = qwtb('OADEV', DI, CS);
        figure('visible','off')
        hold on
        title(['allan dev. of ' varlong ' (' c_legends{1} '), cal. point: A=' num2str(wv.listamp(ind_amp)) ', f=' num2str(wv.listfr(ind_fr))]);
        plot(DO_ADEV.tau.v, DO_ADEV.adev.v, '-k')
        plot(DO_OADEV.tau.v, DO_OADEV.oadev.v, '-r')
        xlabel('tau (s)');
        ylabel(['allan dev. of ' varaxislbl]);
        legend('ADEV', 'OADEV', 'location', 'southoutside','orientation','horizontal')
        print_cpu_indep([data.resdir filesep varshort '_adev_' num2str(count, '%02d') '-' num2str(ind_amp, '%02d') '-' num2str(ind_fr, '%02d')], data.cokl)
        hold off
endfunction

function calc_corr(cal_mat, methodname, wv, data, varlong, varshort, varaxislbl) % %<<<1
        % matrix for correlations: columns are variables, every row is one observation
        mat = [];
        axislbls = {};
        count = 0;
        % for frequencies:
        for j = 1:size(cal_mat,2)
                % for amplitudes:
                for i = 1:size(cal_mat,1)
                        count = count + 1;
                        mat = [mat cal_mat(i, j, :)(:)];
                        axislbl{count} = [num2str(wv.listamp(i)) 'V' num2str(wv.listfr(j)) 'Hz'];
                endfor
        endfor

        pears = corr(mat);
        spear = spearman(mat);
        if data.cokl
                % takes too much memory, so only on cokl:
                kend = kendall(mat); 
        endif

        % pearson corr coef %<<<2
        figure('visible','off')
        imagesc(pears)
        colormap('jet');colorbar;
        pv.ytick = [1:count];
        pv.yticklabel = axislbl;
        pv.xtick = [];
        pv.xticklabel = {};
        set(gca(),pv)

        offset = 2.5;
        for i = 1:count
                ht = text(i, count + offset, axislbl{i});
                set(ht,'rotation',90);
        endfor

        title([varlong, ', pearson corr.']);
        print_cpu_indep([data.resdir filesep varshort '_corr_pears_' methodname], data.cokl)

        % spearman corr coef %<<<2
        figure('visible','off')
        imagesc(spear)
        colormap('jet');colorbar;
        pv.ytick = [1:count];
        pv.yticklabel = axislbl;
        pv.xtick = [];
        pv.xticklabel = {};
        set(gca(),pv)

        offset = 2.5;
        for i = 1:count
                ht = text(i, count + offset, axislbl{i});
                set(ht,'rotation',90);
        endfor

        title([varlong, ', spearman corr.']);
        print_cpu_indep([data.resdir filesep varshort '_corr_spear_' methodname], data.cokl)

        if data.cokl
                % kendall corr coef %<<<2
                figure('visible','off')
                imagesc(kend)
                colormap('jet');colorbar;
                pv.ytick = [1:count];
                pv.yticklabel = axislbl;
                pv.xtick = [];
                pv.xticklabel = {};
                set(gca(),pv)

                offset = 2.5;
                for i = 1:count
                        ht = text(i, count + offset, axislbl{i});
                        set(ht,'rotation',90);
                endfor

                title([varlong, ', kendall corr.']);
                print_cpu_indep([data.resdir filesep varshort '_corr_kend_' methodname], data.cokl)
        endif



endfunction

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
