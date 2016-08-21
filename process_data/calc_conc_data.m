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

% ------------------ plot per method ------------------ %<<<1
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_A_PSFE, 'PSFE', wv, data, 'Amplitude', 'A');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_A_FFT, 'FFT', wv, data, 'Amplitude', 'A');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_A_FPNLSF, 'FPNLSF', wv, data, 'Amplitude', 'A');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_ph_PSFE, 'PSFE', wv, data, 'Phase', 'ph');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_ph_FFT, 'FFT', wv, data, 'Phase', 'ph');
plot_cal_mat_one_method(tvec, wv.sectimestartgrid, cal_mat_ph_FPNLSF, 'FPNLSF', wv, data, 'Phase', 'ph');

% ------------------ plot per calibration point ------------------ %<<<1
plot_types = {'kx-', 'rx-', 'gx-', 'bx-', 'cx-', 'mx-', 'ko-', 'ro-', 'go-', 'bo-', 'co-', 'mo-', 'k*-', 'r*-', 'g*-', 'b*-', 'c*-', 'm*-',};

count = 0;
% for frequencies:
for j = 1:size(cal_mat_A_PSFE,2)
        % for amplitudes:
        for i = 1:size(cal_mat_A_PSFE,1)
                count = count + 1;
                t = tvec + wv.sectimestartgrid(i, j);

                % time developement of amplitude %<<<2
                figure('visible','off')
                hold on
                title(['time developement, cal. point: A=' num2str(wv.listamp(i)) ', f=' num2str(wv.listfr(j))]);
                plot(t, cal_mat_A_PSFE(i, j, :)(:)', plot_types{1})
                plot(t, cal_mat_A_FFT(i, j, :)(:)', plot_types{2})
                plot(t, cal_mat_A_FPNLSF(i, j, :)(:)', plot_types{3})
                xlabel('t (s)');
                ylabel('U (V)');
                legend('PSFE', 'FFT', 'FPNLSF', 'location', 'southoutside','orientation','horizontal')
                print_cpu_indep([data.resdir filesep 'A_time_' num2str(count, '%02d') '-' num2str(i, '%02d') '-' num2str(j, '%02d')], data.cokl)
                hold off

                % allan of amplitude %<<<2
                DI.Ts.v = sum(wv.secpoint)./adc.fs;
                DI.y.v = cal_mat_A_PSFE(i, j, :)(:)';
                CS.verbose = 0;
                DO_ADEV = qwtb('ADEV', DI, CS);
                DO_OADEV = qwtb('OADEV', DI, CS);
                figure('visible','off')
                hold on
                title(['allan dev. of amplitude (PSFE), cal. point: A=' num2str(wv.listamp(i)) ', f=' num2str(wv.listfr(j))]);
                plot(DO_ADEV.tau.v, DO_ADEV.adev.v, '-k')
                plot(DO_OADEV.tau.v, DO_OADEV.oadev.v, '-r')
                xlabel('tau (s)');
                ylabel('allan dev. (V)');
                legend('ADEV', 'OADEV', 'location', 'southoutside','orientation','horizontal')
                print_cpu_indep([data.resdir filesep 'A_adev_' num2str(count, '%02d') '-' num2str(i, '%02d') '-' num2str(j, '%02d')], data.cokl)
                hold off

                % time developement of sfdr %<<<2
                figure('visible','off')
                hold on
                title(['spurious free dynam. ratio, cal. point: A=' num2str(wv.listamp(i)) ', f=' num2str(wv.listfr(j))]);
                plot(t, cal_mat_SFDR(i, j, :)(:)', plot_types{1})
                plot(t, cal_mat_SFDR_FFT(i, j, :)(:)', plot_types{2})
                xlabel('t (s)');
                ylabel('SFDR (dBc)');
                legend('method: sine fitting', 'method: FFT', 'location', 'southoutside','orientation','horizontal')
                print_cpu_indep([data.resdir filesep 'SFDR_time_' num2str(count, '%02d') '-' num2str(i, '%02d') '-' num2str(j, '%02d')], data.cokl)
                hold off

                % allan of sfdr %<<<2
                DI.Ts.v = sum(wv.secpoint)./adc.fs;
                DI.y.v = cal_mat_SFDR(i, j, :)(:)';
                CS.verbose = 0;
                DO_ADEV = qwtb('ADEV', DI, CS);
                DO_OADEV = qwtb('OADEV', DI, CS);
                figure('visible','off')
                hold on
                title(['allan dev. of SFDR (sin. fit), cal. point: A=' num2str(wv.listamp(i)) ', f=' num2str(wv.listfr(j))]);
                plot(DO_ADEV.tau.v, DO_ADEV.adev.v, '-k')
                plot(DO_OADEV.tau.v, DO_OADEV.oadev.v, '-r')
                xlabel('tau (s)');
                ylabel('allan dev. (V)');
                legend('ADEV', 'OADEV', 'location', 'southoutside','orientation','horizontal')
                print_cpu_indep([data.resdir filesep 'SFDR_adev_' num2str(count, '%02d') '-' num2str(i, '%02d') '-' num2str(j, '%02d')], data.cokl)
                hold off

        endfor
endfor

endfunction

function plot_cal_mat_one_method(tvec, sectimestartgrid, cal_mat, methodname, wv, data, varlong, varshort) % %<<<1
% plots timedvelopement for all calibration points for selected method
        plot_types = {'kx-', 'rx-', 'gx-', 'bx-', 'cx-', 'mx-', 'ko-', 'ro-', 'go-', 'bo-', 'co-', 'mo-', 'k*-', 'r*-', 'g*-', 'b*-', 'c*-', 'm*-',};
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
        title([ varlong ', time developement, all calibration points']);
        xlabel('t (s)');
        ylabel('U (V)');
        legend(legendcell);
        legend('location', 'eastoutside');
        print_cpu_indep([data.resdir filesep varshort '_time_' methodname], data.cokl)
        hold off
endfunction
