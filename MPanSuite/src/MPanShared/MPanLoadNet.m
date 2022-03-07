function [ varargout ] = MPanLoadNet(FILE)
%MPanLoadNet loads a PAN netlist.
%
% Usage: STATUS = MPanLoadNet(FILE)
%                 MPanLoadNet(FILE)
%
% STATUS = MpanLoadNet(FILE) check il FILE exist in the Matlab path.
% If it exists (STATUS = 1) then a FILE.raw folder is created in the
% directory containing FILE and the netlist described
% in FILE is loaded by PAN. If FILE doesnot exist STATUS = 0.
% Actually it correspond to the command "pan FILE" which mean that PAN read
% the netlist and executes all the analyses that are specified in FILE. If
% no analyses are found the netlist is simply loaded and it will be
% available for further operations running the MPanSuite commands.
%
% MPanLoadNet(FILE) works as above but no output is provided.
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/02/10$

global MPanSuite_NETLIST_INFO
MPanSuite_NETLIST_INFO = struct('MPanSuite_NETLIST_NAME',[],...
                                'MPanSuite_NETLIST_LOG',[],...
                                'MPanSuite_NETLIST_DIR',[],...
                                'MPanSuite_NETLIST_RAW_DIR',[]);

if nargout > 2
    error('MPanSuiteError: no more than two output variables can be specified.');
end

if exist(FILE,'file') == 2
    netlist_path = which(FILE,'-all');
    if numel(netlist_path) > 1
        display(netlist_path);
        warning('MPanSuiteWarning: More than one %s netlist has been found in the Matlab PATH. Use the complete netlist path in FILE.', FILE);
        warning('MPanSuiteWarning: The netlist has not been loaded.');
    else
        if nargout > 0
            varargout{1} = 1;
        end
        
        [SIM_PATH,FILENAME,FILEXT] = fileparts(FILE);
        
        MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_DIR = SIM_PATH;
        
        if strcmp(FILEXT,'.pan')
            FILE_RADIX = FILENAME;
        else
            FILE_RADIX = [FILENAME FILEXT];
        end
        
        MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME = FILE_RADIX;
        
        RAW_FILES_DIR = [fullfile(SIM_PATH,FILE_RADIX) '.raw'];
        MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_RAW_DIR = RAW_FILES_DIR;
        
        LOG_FILE = [fullfile(SIM_PATH,FILE_RADIX) '.log'];
        MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_LOG = LOG_FILE;
        
        pannet([FILE ' -l ' LOG_FILE ' -r ' RAW_FILES_DIR]);
                
        % include in the MPanSuite PATH the folders created after netlist
        % loading
        tmp = genpath(SIM_PATH);
        addpath(tmp);
    end
else
    if nargout > 0
        varargout{1} = 0;
    end
    warning('MPanSuiteWarning: The requested netlist %s cannot be found in the Matlab PATH. Try using the complete netlist path in FILE.', FILE);
    warning('MPanSuiteWarning: The netlist has not been loaded.');
end
