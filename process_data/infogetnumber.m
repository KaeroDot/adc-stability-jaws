## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{number} = infogetnumber (@var{infostr}, @var{key})
## Parse info string @var{infostr}, finds line line with content "key:: value" and returns 
## the value as number.
##
## Whitecharacters can be before key, after key, before or after delimiter (::) or after key.
## Keys can contain any character but newline. Value can be anything but newline. Any text 
## can be inserted in between lines. Matrices are stored as semicolon delimited values, space
## characters are not important, however semicolon must be right after a numeric value. Sections
## are used e.g. for multiple keys with same values.
##
## Example:
## @example
## infostr="A:: a\n  B   ::    b \nC:: c1 \ncC:: c2 \nD:: 4 \nsome note \n  another note \nE([V?*.]):: e \n#startmatrix:: smallmat \n        1; 2; 3; \n   4;5;         6;  \n#endmatrix:: smallmat \n#startsection:: section 1 \n        D:: 44 \n#endsection:: section 1"
## infogetnumber(infostr,'D')
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 1.4
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: N/A

function number = infogetnumber(infostr,key) %<<<1
        % check inputs
        if (nargin~=2)
                print_usage()
        endif

        if (~ischar(infostr) || ~ischar(key))
                error("infogetnumber: infostr and key must be strings")
        endif

        % get number as text:
        try
                text = infogettext(infostr,key);
        catch
                [msg, msgid]=lasterr;
                id = findstr(msg, 'infogettext: key');
                if isempty(id)
                        % unknown error
                        error(msg)
                else
                        % infogettext error change to infogetnumber error:
                        msg = ['infogetnumber' msg(12:end)];
                        error(msg)
                endif
        end_try_catch
        number = str2num(text);
        if isempty(number)
                error(["infogetnumber: key '" key "' do not contain numeric data"])
        endif
endfunction

% --------------------------- tests: %<<<1

%!shared infostr
%! infostr="A:: a\n  B   ::    b \nC:: c1 \ncC:: c2 \nD:: 4 \nsome note \n  another note \nE([V?*.]):: e \n#startmatrix:: smallmat \n        1; 2; 3; \n   4;5;         6;  \n#endmatrix:: smallmat \n#startsection:: section 1 \n        D:: 44 \n#endsection:: section 1";
%!assert(infogetnumber(infostr,'D')==4)

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
