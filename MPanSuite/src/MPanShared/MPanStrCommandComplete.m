function [str_command, OPTIONS] = MPanStrCommandComplete(str_command, varargin)
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2022.
% Revision: 2.0 $Date: 2022/03/10$

OPTIONS = MPanOptions(varargin{:});

KeyNames = fieldnames(OPTIONS);
m = numel(KeyNames);
for k = 1:m
    key = KeyNames{k};
    if ~isempty(OPTIONS.(key))
        if strcmp(key,'savelist') || strcmp(key,'mem') || strcmp(key,'statevars')
            str_command = MPanListOfWords(str_command, OPTIONS, key);
        elseif strcmp(key,'vprobe')
            nrow = numel(OPTIONS.(key));
            if nrow > 2
                error('MPanSuiteError: vprobe options must be a list with 1 or 2 elements.')
            else
                str_command = MPanListOfWords(str_command, OPTIONS, key);
            end
        elseif strcmp(key,'save') || strcmp(key,'load')
            str_command = strcat([str_command ' ' key ' = "'],OPTIONS.(key),'"');
        elseif ischar(OPTIONS.(key))
            str_command = [str_command ' ' key ' = ' OPTIONS.(key)]; %#ok<*AGROW>
        elseif isstring(OPTIONS.(key))
            str_command = strcat([str_command ' ' key ' = "'],OPTIONS.(key),'"'); %#ok<*AGROW>
        elseif islogical(OPTIONS.(key))
            str_command = [str_command ' ' key ' = ' ,num2str(OPTIONS.(key))]; %#ok<*AGROW>
        else
            str_command = [str_command ' ' key ' = ' ,num2str(OPTIONS.(key),'%23.16e')];
        end
    end
end
str_command = sprintf('%s',str_command);
end

function str_command = MPanListOfWords(str_command, OPTIONS, key)
nrow = numel(OPTIONS.(key));

str_command = [str_command ' ' key ' = [']; %#ok<*AGROW>
for j = 1:nrow
    if isstring(OPTIONS.(key))
        str_command = [str_command '"' OPTIONS.(key){j} '"'];
    elseif iscell(OPTIONS.(key))
        tmp=OPTIONS.(key){j};
        if isstring(tmp)
            str_command = [str_command '"' tmp{1} '"'];
        elseif ischar(tmp)
            str_command = [str_command '"' tmp '"'];
        else
            error(['"' key '" must be an array of srings or an array of cells containing strings or chars']);
        end
    else
        error(['"' key '" must be an array of srings or an array of cells containing strings or chars']);
    end
    if j<nrow
        str_command = [str_command ', '];
    else
        str_command = [str_command '] '];
    end
end
end