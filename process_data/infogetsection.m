## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{section} = infogetsection (@var{infostr}, @var{key})
## Parse info string @var{infostr} and returns lines preceded by line with content
## "#startsection:: key" and succeeded by line "#endsection:: key".
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
## infogetnumber(infogetsection(infostr,'section 1'), 'D')
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 1.5
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: yes

function section = infogetsection(infostr, key) %<<<1
        % check inputs
        if (nargin~=2)
                print_usage()
        endif

        if (~ischar(infostr) || ~ischar(key))
                error('infogetsection: str and key must be strings')
        endif

        key = strtrim(key);
        % escape characters of regular expression special meaning:
        key = regexpescape(key);

        [S, E, TE, M, T, NM] = regexpi (infostr,['#startsection\s*::\s*' key '(.*)' '#endsection\s*::\s*' key], 'once');
        if isempty(T)
                error(["infogetsection: section '" key "' not found"])
        endif
        section=strtrim(T{1});
endfunction

function key = regexpescape(key)
        % Translate all special characters (e.g., '$', '.', '?', '[') in
        % key so that they are treated as literal characters when used
        % in the regexp and regexprep functions. The translation inserts
        % an escape character ('\') before each special character.
        % additional characters are translated, this fixes error in octave
        % function regexptranslate.

        key = regexptranslate('escape', key);
        % test if octave error present:
        if strcmp(regexptranslate('escape','*(['), '*([')
                % fix octave error not replacing other special meaning characters:
                key = regexprep(key, '\*', '\*');
                key = regexprep(key, '\(', '\(');
                key = regexprep(key, '\)', '\)');
        endif
endfunction

% --------------------------- tests: %<<<1

%!shared infostr
%! infostr="A:: a\n  B   ::    b \nC:: c1 \ncC:: c2 \nD:: 4 \nsome note \n  another note \nE([V?*.]):: e \n#startmatrix:: smallmat \n        1; 2; 3; \n   4;5;         6;  \n#endmatrix:: smallmat \n#startsection:: section 1 \n        D:: 44 \n#endsection:: section 1";
%!assert(strcmp(infogetsection(infostr, 'section 1'), 'D:: 44'))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
