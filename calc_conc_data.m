% calculates and plots informations from concatenated data
function calc_conc_data(res, wv, adc, data)
% ------------------ generate calibration matrix ------------------ %<<<1
% indexes: row          column          sheet
%          amplitude    frequency       time
cal_mat_PSFE = cat(3, res.A_PSFE);
cal_mat_FFT = cat(3, res.A_PSFE);
tvec = [res.t];

% ------------------ plot time development, per method ------------------ %<<<1

plot_cal_mat_one_method(tvec, res(1).timestart, cal_mat_PSFE, 'PSFE', data);
plot_cal_mat_one_method(tvec, res(1).timestart, cal_mat_FFT, 'FFT', data);

% ------------------ plot time development and allan, per calibration point ------------------ %<<<1
plot_types = {'kx-', 'rx-', 'gx-', 'bx-', 'cx-', 'mx-', 'ko-', 'ro-', 'go-', 'bo-', 'co-', 'mo-', 'k*-', 'r*-', 'g*-', 'b*-', 'c*-', 'm*-',};

count = 0;
for i = 1:size(cal_mat_PSFE,1)
        for j = 1:size(cal_mat_PSFE,2)
                count = count + 1;
                t = tvec - res(1).timestart(i, j);
                figure('visible','off')
                hold on
                plot(t, cal_mat_PSFE(i, j, :)(:)', plot_types{1})
                plot(t, cal_mat_FFT(i, j, :)(:)', plot_types{2})
                legend('PSFE', 'FFT', 'location', 'southoutside')
                print_cpu_indep([data.resdir filesep 'whole_timedev_' num2str(count, '%02d')], data.cokl)
                hold off

                DI.Ts.v = sum(wv.pointsec)./adc.fs;
                DI.y.v = cal_mat_PSFE(i, j, :)(:)';
                CS.verbose = 0;
                DO_ADEV = qwtb('ADEV', DI, CS);
                DO_OADEV = qwtb('OADEV', DI, CS);
                figure('visible','off')
                hold on
                plot(DO_ADEV.tau.v, DO_ADEV.adev.v, plot_types{1})
                plot(DO_OADEV.tau.v, DO_OADEV.oadev.v, plot_types{2})
                legend('ADEV', 'OADEV', 'location', 'southoutside')
                print_cpu_indep([data.resdir filesep 'whole_adev_' num2str(count, '%02d')], data.cokl)
                hold off

        endfor
endfor

endfunction

function plot_cal_mat_one_method(tvec, timestart, cal_mat, methodname, data) % %<<<1
        plot_types = {'kx-', 'rx-', 'gx-', 'bx-', 'cx-', 'mx-', 'ko-', 'ro-', 'go-', 'bo-', 'co-', 'mo-', 'k*-', 'r*-', 'g*-', 'b*-', 'c*-', 'm*-',};
        count = 0;
        figure('visible','off')
        hold on
        for i = 1:size(cal_mat,1)
                for j = 1:size(cal_mat,2)
                        count = count + 1;
                        % XXX get allan variation
                        plot(tvec - timestart(i, j), cal_mat(i, j, :)(:)' - cal_mat(i, j, 1), plot_types{count})
                endfor
        endfor
        print_cpu_indep([data.resdir filesep 'whole_timedev_' methodname], data.cokl)
        hold off
endfunction
