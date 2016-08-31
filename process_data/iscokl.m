## Copyright (C) 2016 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} ischar ()
## Return true if octave is run on CMI supercomputer 'cokl'.
## In the case of internal errors returns false.
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2016
## Version: 1.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: N/A
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

function l = iscokl() %<<<1

% automatic detection of CMI supercomputer named "cokl":
[s, o] = system('uname -n');
l = strcmpi(deblank(o), 'vsmp1');

endfunction

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
