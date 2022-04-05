function DATA = MPanVarGetRawFile(FILE, LIST, varargin)
% DATA = MPanVarInRawFile(FILE, LIST, STRATEGY) returns a set of variables,
% stored in the RAW file named FILE, specified in LIST.
%
% Usage: DATA = MPanVarGetRawFile(FILE, LIST, STRATEGY)
%
% DATA = MPanVarInRawFile(FILE, LIST, STRATEGY) returns a set of variables,
% stored in the RAW file named FILE, specified in LIST.
% LIST = MPanVarInRawFile(FILE) LIST can be either a cell,
% array if text labes or both text labels and integer indices are used to
% indentify the requested variables, or a vector of integer if only indices
% are used. Whatever the indexing choice, a variable must be present only
% once in LIST. If STRATEGY is not specified it assumed to be SLOW. The
% user can choose between FAST and SLOW. The FAST mode laod in memory the
% whole FILE and then discards the columns not required trought LIST. If
% SLOW mode is selected then the FILE is read one row at a time. If FILE
% is large with respect to the RAM size the SLOW mode is recommended.
%
% See also
%    MPanVarInRawFile
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2015.
% Revision: 2.0 $Date: 2022/03/10$
if nargin < 2 || nargin > 3
    error('MPanSuiteError: 2 or 3 inputs are needed.');
elseif nargin == 2
    STRATEGY = 'SLOW';
elseif nargin == 3
    if (strcmp(varargin{1},'SLOW') || strcmp(varargin{1},'FAST'))
        STRATEGY = varargin{1};
    else
        warning(['MPanSuiteWarning: STRATEGY must be set to SLOW or ' ...
            'FAST. %s has been wrongly chose and SLOW is assumed'],...
            varargin{1});
        STRATEGY = 'SLOW';
    end
end

switch STRATEGY
    case 'SLOW'
        slow = true;
    case 'FAST'
        slow = false;
end
        
DATA = [];

[GETLIST, FULL_FILE_NAME] = MPanVarInRawFile(FILE);
if isempty(GETLIST)
    DATA = [];
    return
end

num_var = numel(GETLIST);

if isnumeric(LIST)
    if numel(unique(LIST)) < numel(LIST)
        warning(['MPanSuiteWarning: the output variables must compare ' ...
            'only once in the input LIST.']);
        return
    else
        [C1, ia, ib] = intersect([GETLIST(1:end).VAR_INDEX],LIST);
        [C2, i1] = setdiff(LIST,C1);
        if ~isempty(C2)
            warning(['MPanSuiteWarning: one or more of the variables ' ...
                'indexed in the input LIST are not found in %s. ' ...
                'They have been indexed as:\n'],FILE);
            display(LIST(i1));
            return
        end
    end
else
    ib = 1:numel(LIST);
    ia = numel(LIST);
    for j = 1:numel(LIST)
        k = 1;
        GO = true;
        while k < num_var + 1 && GO
            if isnumeric(LIST{j}) && GETLIST(k).VAR_INDEX == LIST{j}
                ia(j) = GETLIST(k).VAR_INDEX + 1;
                GO = false;
            elseif strcmp(GETLIST(k).VAR_NAME,LIST{j})
                ia(j) = GETLIST(k).VAR_INDEX + 1;
                GO = false;
            end
            k = k +1;
        end
        if GO
            warning(['MPanSuiteWarning: at least one of the variables ' ...
                'in the input LIST are not found in %s. ' ...
                'The first one is:'],FILE);
            display(LIST{j});
            return
        end
    end
    if numel(unique(ia)) < numel(LIST)
        warning(['MPanSuiteWarning: the output variables must compare ' ...
            'only once in the input LIST. In LIST there are two or ' ... 
            'more equal indices, labels corresponding to indices or ' ...
            'viceversa or both.']);
        return
    end
end

fileID = fopen(FULL_FILE_NAME);
ch1='';
ch2='';
ch3='';
ch4='';
ch5='';
ch6='';
ch7='';
while ~strncmp([ch1 ch2 ch3 ch4 ch5 ch6 ch7],'Binary:',7)
    ch1 = ch2;
    ch2 = ch3;
    ch3 = ch4;
    ch4 = ch5;
    ch5 = ch6;
    ch6 = ch7;
    ch7 = fread(fileID, 1, 'uint8=>char');
    if( feof( fileID ) )
        fclose(fileID);
        DATA = [];
        return;
    end
end
fread(fileID, 1, 'uint8=>char');

num_samples = GETLIST(1).NUM_SAMPLES;
DATA = zeros(num_samples,numel(LIST));

if slow
    if ~strncmp(GETLIST(1).FLAGS,'complex',7)
        for k = 1:num_samples
            A = fread(fileID,[num_var 1],'real*8');
            DATA(k,ib) = A(ia);
        end
    else
        for k = 1:num_samples
            A = fread(fileID,[num_var*2 1],'real*8');
            for h = 1:numel(ib) 
                DATA(k,ib(h))=complex(A(2*ia(h)-1),A(2*ia(h)));
            end
        end
    end
else
    if ~strncmp(GETLIST(1).FLAGS,'complex',7)
        tmp = fread(fileID,[num_var num_samples],'real*8');
        DATA(:,ib) = transpose(tmp(ia,:));
    else
        tmp = fread(fileID,[num_var*2 num_samples],'real*8');
        tmp = transpose(tmp);
        for h = 1:numel(ib)            
            DATA(:,ib(h))=complex(tmp(:,2*ia(h)-1),tmp(:,2*ia(h)));
        end
    end
end
fclose(fileID);
