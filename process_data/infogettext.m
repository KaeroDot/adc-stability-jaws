## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettext (@var{infostr}, @var{key})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as text.
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
## infogettext(infostr,'E([V?*.])')
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

function text = infogettext(infostr,key) %<<<1
        % check inputs
        if (nargin~=2)
                print_usage()
        endif

        if (~ischar(infostr) || ~ischar(key))
                error('infogettext: infostr and key must be strings')
        endif

        % regexp for rest of line after a key:
        rol = '\s*::([^\n]*)';

        % first remove all sections, to prevent finding
        % key inside of some section
        do
                % fid key of some section:
                [S, E, TE, M, T, NM] = regexpi (infostr,['#startsection' rol], 'once');
                if isempty(T)
                        % no more keys, break loop
                        break
                else
                        seckey = strtrim(T{1});
                        % escape characters:
                        seckey = regexpescape(seckey);
                        % find whole section:
                        [S, E, TE, M, T, NM] = regexpi (infostr,['#startsection\s*::\s*' seckey '.*' '#endsection\s*::\s*' seckey], 'once');
                        % remove section from string:
                        infostr = [infostr(1:S-1) infostr(E+1:end)];
                endif
                % this is infinite loop, however in every loop 
                % reduction of str should happen, therefore 
                % loop should end every time, hopefully...
        until 0

        %remove leading spaces of key:
        key = strtrim(key);
        % escape characters:
        key = regexpescape(key);
        % find line with the key:
        % (?m) is regexp flag: ^ and $ match start and end of line
        [S, E, TE, M, T, NM] = regexpi (infostr,['(?m)^\s*' key rol]);
        % return key if found:
        if isempty(T)
                error(["infogettext: key '" key "' not found"])
        else
                if isscalar(T)
                        text = strtrim(T{1}{1});
                else
                        error(["infogettext: key '" key "' found on multiple places"])
                endif
        endif
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
%!assert(strcmp(infogettext(infostr,'A'),'a'))
%!assert(strcmp(infogettext(infostr,'C'),'c1'))
%!assert(strcmp(infogettext(infostr,'E([V?*.])'),'e'))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
