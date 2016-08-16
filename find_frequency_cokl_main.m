tmp = [11200:1:1];
multcell = mat2cell(tmp);
allres = parcellfun(50, @find_frequency_cokl, "VerboseLevel", 1);
