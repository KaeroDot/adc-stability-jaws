## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infoload (@var{filename}, [@var{autoextension}])
## Opens file @var{filename}.info and loads its content as text. If @var{autoextension}
## is zero, '.info' extension is not added.
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 1.3
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

function infostr = infoload(filename, autoextension = 1) %<<<1
        % check inputs
        if ~(nargin==1 || nargin==2)
                print_usage()
        endif

        if (~ischar(filename))
                error('infoload: filename must be string')
        endif

        % check if file exists:
        if autoextension
                filename = [filename '.info'];
        endif
        F =  glob(filename);

        if isempty(F)
                error(["infoload: file '" filename "' not found"])
        endif

        fid = fopen(filename,"r");
        if fid == -1
                error(["infoload: error opening file '" filename "'"])
        endif
        [infostr,count] = fread(fid, [1,inf], 'uint8=>char');  % s will be a character array, count has the number of bytes
        fclose(fid);
endfunction

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
