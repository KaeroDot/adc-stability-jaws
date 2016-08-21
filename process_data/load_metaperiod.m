% loads one metaperiod from the file and calls calculation of one metaperiod

function res = load_metaperiod(pars)

% open file:
fid = fopen([pars.data.filenamepart '.bin'], 'r');

% set pointer to the beginning of current metaperiod:
fseek(fid, pars.data.startpoint.*sizeof(int32(0)));
% read points for whole metaperiod:
[tmp, count] = fread(fid, sum(pars.wv.secpoint), 'int32', 0, 'ieee-le');

% if full metaperiod loaded:
if size(tmp,1) == sum(pars.wv.secpoint)
        % get real values:
        tmp = pars.adc.offset + tmp.*pars.adc.gain;
        % and process data
        res = calc_metaperiod(tmp, pars.wv, pars.adc, pars.data);
endif

% close file:
fclose(fid);

endfunction
