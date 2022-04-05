function [varargout] = MPanVarInRawFile(FILE)
% [varargout] = MPanVarInRawFile(FILE) returns the LIST of the variable in the RAW
%file named FILE
%
% Usage: LIST = MPanVarInRawFile(FILE)
%        [LIST, FULL_FILE_PATH] = MPanVarInRawFile(FILE)
%
% LIST = MPanVarInRawFile(FILE) checks if the global variable
% MPan_NETLIST_INFO exist. In this case it looks for FILE in such a
% directory. If the global variable does not exist or if FILe is not in it,
% it looks for FILE in the Matlab path. If FILE is not found or if more
% than one FILE is found it returns an empty LIST and remark this situation
% with a proper warning.
%
% [LIST, FULL_FILE_PATH] = MPanVarInRawFile(FILE) works as above and
% moreover the full name of the requested file is given.
%
% See also
%    MPanVarGetRawFile
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.1 $Date: 2015/08/04$
if nargout > 2
    error('MPanSuiteError: no more than two output variables can be specified.');
end

if nargout == 0
    error('MPanSuiteError: at least one output is provided.');
elseif nargout == 1
    varargout{1} = [];
elseif nargout == 2
    varargout{1} = [];
    varargout{2} = [];
end

global MPanSuite_NETLIST_INFO

if ~isempty(MPanSuite_NETLIST_INFO) && ...
        ~isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR) && ...
         exist([MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR '/' FILE],'file')
    
    FULL_FILE_NAME = [MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR '/' FILE]; 
else
    if exist(FILE,'file') == 2
        [fpath, fname, fextension] = fileparts(FILE);
        netlist_path = which([fpath '/' fname '.' fextension],'-all');
        if numel(netlist_path) > 1
            display(netlist_path);
            warning('MPanSuiteWarning: More than one %s netlist has been found in the Matlab PATH. Use the complete netlist path in FILE.', FILE);
            return
        elseif numel(netlist_path)==1
            FULL_FILE_NAME = netlist_path{1};
        else
            FULL_FILE_NAME = FILE;
        end
    else
        warning('MPanSuiteWarning: The requested netlist %s cannot be found in the Matlab PATH. Try using the complete netlist path in FILE.', FILE);
        return
    end
end

fileID = fopen(FULL_FILE_NAME);
tline  = 'INITIAL DUMMY VALUE FOR TLINE';
while ~strncmp(tline,'Binary:',7)
    tline = fgetl(fileID);
    if strncmp(tline,'Flags',5)
        tf  = find(isspace(tline));
        var_type = tline(tf(1)+1: end);
    end
    if strncmp(tline,'No. Variables: ',15)
        tf  = find(isspace(tline));
        num_var = str2double(tline(tf(2)+1: tf(3)-1));
    end
    if strncmp(tline,'No. Points: ',12)
        tf  = find(isspace(tline));
        num_samples = str2double(tline(tf(2)+1: tf(3)-1));
    end
    if strncmp(tline,'Variables: ',12)
        break
    end
end

LIST(1:num_var,1)=struct('VAR_INDEX',NaN,'VAR_NAME',[],'VAR_TYPE',[],'NUM_SAMPLES',NaN,'FLAGS',[]);
for k = 1:num_var
    tline = fgetl(fileID);
    tf  = find(isspace(tline));
    LIST(k).VAR_INDEX = k-1;
    name = char(tline(tf(2)+1:tf(3)-1));
    LIST(k).VAR_NAME  = name;
    LIST(k).VAR_TYPE  = char(tline(tf(4)+1:end));
    LIST(k).NUM_SAMPLES = num_samples;
    LIST(k).FLAGS = var_type;
end

varargout{1} = LIST;
if nargout == 2
    varargout{2} = FULL_FILE_NAME;
end
