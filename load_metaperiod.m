% loads one dataperiod from the file and calls calulation of one metaperiod

function res = load_metaperiod(paramstruct)
data = paramstruct.data;
wv = paramstruct.wv;
adc = paramstruct.adc;
id = paramstruct.id;
startpoint = paramstruct.startpoint;
starttime = paramstruct.starttime;

% open file:
fid = fopen([data.filenamepart '.bin'], 'r');

% set pointer to the beginning of current metaperiod:
fseek(fid, startpoint.*sizeof(int32(0)));
% read points for whole metaperiod:
[tmp, count] = fread(fid, sum(wv.pointsec), 'int32', 0, 'ieee-le');

% if full metaperiod loaded:
if size(tmp,1) == sum(wv.pointsec)
        % get real values:
        tmp = adc.offset + tmp.*adc.gain;
        % plot it (only for first run):
        %%%%if id == 1
                if data.wvplot
                        figure('visible','off')
                        plot(tmp);
                        print_cpu_indep([data.resdir filesep 'wv' num2str(id, '%06d')], data.cokl)
                endif
        %%%%endif
        % and process data
        res = calc_metaperiod(id, tmp, wv, adc, data);
        res.timestart = starttime;
endif

% close file:
fclose(fid);

endfunction
