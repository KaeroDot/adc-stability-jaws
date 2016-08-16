paramcell = num2cell([1:1:11200]);
allres = parcellfun(50, @find_frequency2, paramcell, "VerboseLevel", 1);
%allres = cellfun(@find_frequency_cokl, paramcell);
[[allres.adcfs]{:}]
