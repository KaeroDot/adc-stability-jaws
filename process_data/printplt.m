## Copyright (C) 2014 Martin Šíra
##

## -*- texinfo -*-
## @deftypefn {Function File} printplt(@var{filenamepart}, [@var{terminal}])
## Prints current plot to a .plt file by means of drawnow.
## Resulted file contains a script for gnuplot to generate the same 
## plot. Usefull for later viewing of the figure with zomming ability 
## contrary to fixed png or pdf outputs. Also usefull to change details
## of the plot without running the whole calculation again.
##
## @var{filenamepart}: file part of the result .plt file. Can 
## contain path. Extension '.plt' is added automatically.
##
## @var{terminal}: gnuplot terminal. Default value is set to 'wxt'.
##
## Example:
## @example
## plot([1,2,3]);
## printplt('plot_example');
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 1.1
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

function printplt(filename, terminal='wxt')

        % check input values:
        if ( nargin < 1 || nargin > 2 ) 
                print_usage();
        endif
        if ( ~ischar(filename) )
                error ("printplt: input filename has to be character array data type");
        endif
        if ( isempty(filename) ) 
                error ("printplt: input filename is empty");
        endif
        if ( ~ischar(terminal) ) 
                error ("printplt: terminal must be a string");
        endif

        % print plot to plt:
        drawnow (terminal, "/dev/null", false, [filename '.plt'])

endfunction

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
