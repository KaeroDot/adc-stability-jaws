% calculates and plots informations from concatenated data
function plot_conc_data(cres, wv, adc, data)
% create plot directory if missing:
if ~exist(data.plotdir, 'dir')
        mkdir(data.plotdir);
endif

% ------------------ plot per method all cal points in one plot ------------------ %<<<1
plot_cal_mat_one_method(cres.cal_mat.f.PSFE, 'PSFE', 'Frequency', 'f', 'f (Hz)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.f.FFT, 'FFT', 'Frequency', 'f', 'f (Hz)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.f.FPNLSF, 'FPNLSF', 'Frequency', 'f', 'f (Hz)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.A.PSFE, 'PSFE', 'Amplitude', 'A', 'Amp (V)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.A.FFT, 'FFT', 'Amplitude', 'A', 'Amp (V)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.A.FPNLSF, 'FPNLSF', 'Amplitude', 'A', 'Amp (V)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.SFDR.sinfit, 'sinfit', 'Spur. Free Dyn. Ratio', 'SFDR', 'SFDR (dBc)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.SFDR.FFT, 'FFT', 'Spur. Free Dyn. Ratio', 'SFDR', 'SFDR (dBc)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.ph.PSFE, 'PSFE', 'Phase', 'ph', 'Phase (rad)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.ph.FFT, 'FFT', 'Phase', 'ph', 'Phase (rad)', wv, data);
plot_cal_mat_one_method(cres.cal_mat.ph.FPNLSF, 'FPNLSF', 'Phase', 'ph', 'Phase (rad)', wv, data);

% ------------------ plot per calibration point all methods in one plot ------------------ %<<<1
count = 0;
% for frequencies:
for l = 1:wv.L
        % for amplitudes:
        for k = 1:wv.K
                count = count + 1;
                t = data.tvec + wv.gridsectimestart(k, l);

                % frequency
                plot_cal_point_all_methods_time(k, l, count, data.tvec, {cres.cal_mat.f.PSFE, cres.cal_mat.f.FFT, cres.cal_mat.f.FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Frequency', 'f', 'f (Hz)', wv, data);
                plot_cal_point_all_methods_allan(k, l, count, data.tvec, {cres.cal_p(k, l).f.PSFE, cres.cal_p(k, l).f.FFT, cres.cal_p(k, l).f.FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Frequency', 'f', 'f (Hz)', wv, data);
                % amplitude
                plot_cal_point_all_methods_time(k, l, count, data.tvec, {cres.cal_mat.A.PSFE, cres.cal_mat.A.FFT, cres.cal_mat.A.FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Amplitude', 'A', 'Amp (V)', wv, data);
                plot_cal_point_all_methods_allan(k, l, count, data.tvec, {cres.cal_p(k, l).A.PSFE, cres.cal_p(k, l).A.FFT, cres.cal_p(k, l).A.FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Amplitude', 'A', 'Amp (V)', wv, data);
%               % sfdr
                plot_cal_point_all_methods_time(k, l, count, data.tvec, {cres.cal_mat.SFDR.sinfit, cres.cal_mat.SFDR.FFT}, {'sine fit', 'FFT'}, 'Spurious Free Dynam. Ratio', 'SFDR', 'SFDR (dBc)', wv, data);
                plot_cal_point_all_methods_allan(k, l, count, data.tvec, {cres.cal_p(k, l).SFDR.sinfit, cres.cal_p(k, l).SFDR.FFT}, {'sine fit', 'FFT'}, 'Spurious Free Dynam. Ratio', 'SFDR', 'SFDR (dBc)', wv, data);
%               % phase
                plot_cal_point_all_methods_time(k, l, count, data.tvec, {cres.cal_mat.ph.PSFE, cres.cal_mat.ph.FFT, cres.cal_mat.ph.FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Phase', 'ph', 'ph (rad)', wv, data);
                plot_cal_point_all_methods_allan(k, l, count, data.tvec, {cres.cal_p(k, l).ph.PSFE, cres.cal_p(k, l).ph.FFT, cres.cal_p(k, l).ph.FPNLSF}, {'PSFE', 'FFT', 'FPNLSF'}, 'Phase', 'ph', 'ph (rad)', wv, data);

        endfor
endfor

% ------------------ calculate/plot correlation factors ------------------ %<<<1
plot_corr(cres.cal_mat.f.PSFE, 'PSFE', 'Frequency', 'f', 'f (Hz)', wv, data);
plot_corr(cres.cal_mat.A.PSFE, 'PSFE', 'Amplitude', 'A', 'Amplitude (V)', wv, data);
plot_corr(cres.cal_mat.ph.PSFE, 'PSFE', 'Phase', 'ph', 'Phase (rad)', wv, data);
plot_corr(cres.cal_mat.ph.PSFE, 'PSFE', 'Phase', 'ph', 'Phase (rad)', wv, data);
plot_corr(cres.cal_mat.SFDR.sinfit, 'SFDR', 'SFDR', 'SFDR', 'SFDR (dBc)', wv, data);

endfunction %>>>1

function plot_cal_mat_one_method(cmm, methodname, varlong, varshort, varaxislbl, wv, data) % %<<<1
% plots time development for all calibration points for selected method

% cmm - calibration matrix method
% methodname - name of the method
% wv
% data
% varlong - full name of the variable
% varshort - shorted name of the variable
% varaxislbl - label for y axis

        plot_types = {'kx-', 'rx-', 'gx-', 'bx-', 'cx-', 'mx-', 'ko-', 'ro-', 'go-', 'bo-', 'co-', 'mo-', 'k*-', 'r*-', 'g*-', 'b*-', 'c*-', 'm*-'};
        count = 0;
        figure('visible','off')
        legendcell = {};
        hold on
        % for frequencies:
        for l = 1:size(cmm.v,2)
                % for amplitudes:
                for k = 1:size(cmm.v,1)
                        count = count + 1;
                        plot(data.tvec + wv.gridsectimestart(k, l), cmm.v(k, l, :)(:)' - cmm.v(k, l, 1), plot_types{count})
                        legendcell = [legendcell {['A=' num2str(wv.listamp(k)) ',fr=' num2str(wv.listfr(l))]}];
                endfor
        endfor
        title([ varlong ', ' methodname ', time developement, all cal. points, first point subtracted']);
        xlabel('t (s)');
        ylabel(varaxislbl);
        legend(legendcell);
        legend('location', 'eastoutside');
        print_cpu_indep([data.plotdir varshort '_time_' methodname], data.cokl)
        hold off
endfunction

function plot_cal_point_all_methods_time(k, l, count, t, c_cal_mats, c_legends, varlong, varshort, varaxislbl, wv, data) %<<<1
% plot time developement for all methods for particular calibration point and allan deviation of the first method

% j - index of current amplitude section
% l - index of current frequency section
% count - index of current iteration
% t - time vector
% c_cal_mats - cell with calibration-matrix-method
% c_legends - cell with method strings for legends
% varlong - full name of the variable
% varshort - shorted name of the variable
% varaxislbl - label for y axis

        plot_types = {'k-', 'r-', 'g-', 'b-', 'c-', 'm-'};
        % time 
        figure('visible','off')
        hold on
        title([varlong ', cal. point: A=' num2str(wv.listamp(k)) ', f=' num2str(wv.listfr(l))]);
        for i = 1:length(c_cal_mats)
                plot(t, c_cal_mats{i}.v(k, l, :)(:)', plot_types{i})
        endfor
        xlabel('t (s)');
        ylabel(varaxislbl);
        legend(c_legends);
        legend('location', 'southoutside','orientation','horizontal')
        print_cpu_indep([data.plotdir varshort '_time_' num2str(count, '%02d') '-' num2str(k, '%02d') '-' num2str(l, '%02d')], data.cokl)
        hold off

endfunction

function plot_cal_point_all_methods_allan(k, l, count, t, c_cal_ps, c_legends, varlong, varshort, varaxislbl, wv, data) %<<<1
% plot time developement for all methods for particular calibration point and allan deviation of the first method

% j - index of current amplitude section
% l - index of current frequency section
% count - index of current iteration
% t - time vector
% c_cal_ps - cell with calibration-matrix-method for point
% c_legends - cell with method strings for legends
% varlong - full name of the variable
% varshort - shorted name of the variable
% varaxislbl - label for y axis

        plot_types = {'k-', 'r-', 'g-', 'b-', 'c-', 'm-'};
        % allan using the first method in c_cal_ps
        figure('visible','off')
        hold on
        title(['allan dev. of ' varlong ' (' c_legends{1} '), cal. point: A=' num2str(wv.listamp(k)) ', f=' num2str(wv.listfr(l))]);
        plot(c_cal_ps{1}.ADEV.tau, c_cal_ps{1}.ADEV.v, '-k')
        plot(c_cal_ps{1}.OADEV.tau, c_cal_ps{1}.OADEV.v, '-r')
        if isfield(c_cal_ps{1}, 'MADEV')
                plot(c_cal_ps{1}.MADEV.tau, c_cal_ps{1}.MADEV.v, '-b')
        endif
        xlabel('tau (s)');
        ylabel(['allan dev. of ' varaxislbl]);
        if isfield(c_cal_ps{1}, 'MADEV')
                legend('ADEV', 'OADEV', 'MADEV', 'location', 'southoutside','orientation','horizontal')
        else
                legend('ADEV', 'OADEV', 'location', 'southoutside','orientation','horizontal')
        endif
        print_cpu_indep([data.plotdir varshort '_adev_' num2str(count, '%02d') '-' num2str(k, '%02d') '-' num2str(l, '%02d')], data.cokl)
        hold off
endfunction

function plot_corr(cmm, methodname, varlong, varshort, varaxislbl, wv, data) % %<<<1
% plot correlation matrix for current method

% j - index of current amplitude section
% l - index of current frequency section
% count - index of current iteration
% t - time vector
% cmm - calibration matrix method
% methodname - name of method
% c_legends - cell with method strings for legends
% varlong - full name of the variable
% varshort - shorted name of the variable
% varaxislbl - label for y axis

        % matrix for correlations: columns are variables, every row is one observation

        % pearson correlation %<<<2
        figure('visible','off')
        imagesc(cmm.pears)
        colormap('jet');colorbar;
        pv.ytick = [1:length(cmm.corraxislbl)];
        pv.yticklabel = cmm.corraxislbl;
        pv.xtick = [];
        pv.xticklabel = {};
        set(gca(), pv)

        offset = 2.5;
        for i = 1:length(cmm.corraxislbl)
                ht = text(i, length(cmm.corraxislbl) + offset, cmm.corraxislbl{i});
                set(ht,'rotation',90);
        endfor

        title([varlong, ', pearson corr.']);
        print_cpu_indep([data.plotdir varshort '_corr_pears_' methodname], data.cokl)

        % spearman corr coef %<<<2
        figure('visible','off')
        imagesc(cmm.spear)
        colormap('jet');colorbar;
        pv.ytick = [1:length(cmm.corraxislbl)];
        pv.yticklabel = cmm.corraxislbl;
        pv.xtick = [];
        pv.xticklabel = {};
        set(gca(),pv)

        offset = 2.5;
        for i = 1:length(cmm.corraxislbl)
                ht = text(i, length(cmm.corraxislbl) + offset, cmm.corraxislbl{i});
                set(ht,'rotation',90);
        endfor

        title([varlong, ', spearman corr.']);
        print_cpu_indep([data.plotdir varshort '_corr_spear_' methodname], data.cokl)

        if isfield(cmm, 'kend')
                % kendall corr coef %<<<2
                figure('visible','off')
                imagesc(cmm.kend)
                colormap('jet');colorbar;
                pv.ytick = [1:length(cmm.corraxislbl)];
                pv.yticklabel = cmm.corraxislbl;
                pv.xtick = [];
                pv.xticklabel = {};
                set(gca(),pv)

                offset = 2.5;
                for i = 1:length(cmm.corraxislbl)
                        ht = text(i, length(cmm.corraxislbl) + offset, cmm.corraxislbl{i});
                        set(ht,'rotation',90);
                endfor

                title([varlong, ', kendall corr.']);
                print_cpu_indep([data.plotdir varshort '_corr_kend_' methodname], data.cokl)
        endif

endfunction

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
