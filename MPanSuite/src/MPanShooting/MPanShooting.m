function varargout = MPanShooting(NAME, MEMVARS, varargin)
% MPanShooting runs a PAN shooting analysis. A netlist must be already loaded
% with MPanNetLoad.
%
% Usage: MPanTran(NAME, [], varargin)
%        S = MPanTran(NAME, MEMVARS, varargin)
%
% MPanShooting(NAME, [], varargin) runs a PAN shooting analysis whose
% identifier is NAME. The varargin variables
% are used to specify proper OPTIONS to be used by the shooting analysis except "mem".
% varargin must be a sequence of pairs as 'NAME1',VALUE1,'NAME2',VALUE2,...
% where the name of the options and the allowed values are specified by the
% PAN simulator documentation.
% The 'period' options is mandatory for autonomous circuits and is the
% extimated value of the steady state periodic solution that is searched.
% Analogously the 'fund' parameter for non-autonomous circuits.
% An alternative is that the initial guess is loaded from a file storing
% the results of a previous shooting analysis,
% successfully terminated before the current one. In this case, the 'load'
% options must be specified. In case the 'load' options is present and
% one between 'period' and 'fund' is present too, the value in the file is
% overloaded.
% S = MPanShooting(NAME, MEMVARS, varargin) works as the previous one
% but S is an output cell arrays and each cell contains
% a label and a waveform. The waveform are those specified with the MEMVARS
% input. If MEMVARS is empty S is empty. MEMVARS must be an array of
% strings or a cell array of chars or a cell array of strings.
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2015.
% Revision: 2.0 $Date: 2022/03/10$

global MPanSuite_NETLIST_INFO
if isempty(MPanSuite_NETLIST_INFO) || isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME)
    error('MPanSuiteError: a MPanSuiteNetlist is not loaded yet.')
end

if nargin < 3
    error('MPanSuiteError: at least 3 input arguments are required.')
end

if nargout > 1
    error('MPanSuiteError: no more than 1 output can be assigned')
end

if nargin > 3
    if ~isempty(MEMVARS) && nargout == 0
        warning('The MEMVARS input is not empty but no output has been required')
    end
    if rem(nargin,2)  > 0
        error('Beside NAME and MEMVARS an even number of inputs is expected')
    end
end

OPTIONS = MPanOptions(varargin{:});
if not(isfield(OPTIONS,'period')) && not(isfield(OPTIONS,'fund')) && not(isfield(OPTIONS,'load'))
    error('The shooting analysis requires an estimate of the working period or of the fundamental frequency.');
end

str_command = [NAME ' shooting '];


if nargout > 0 && ~isempty(MEMVARS)
    m = size(varargin,2);
    varargin{1,m+1} = 'mem';
    varargin{1,m+2} = MEMVARS;
    NAME_ = NAME;
elseif  nargout > 0 && isempty(MEMVARS)
    warning('The MEMVARS input is empty but an output has been required')
end

if nargin > 2
    str_command = MPanStrCommandComplete(str_command,varargin{:});
end

clear NAME MEMVARS varargin
pansimc(str_command);

MPanUpdateRawFilesList();

if nargout == 1
    if ~isempty(OPTIONS.mem)
        nmem = numel(OPTIONS.mem);
        S = cell(nmem,1);
        tmp = struct('label',[],'signal',[]);
        for k = 1:nmem
            tmp.label = OPTIONS.mem{k};
            c_lab = [NAME_ '.' OPTIONS.mem{k}];
            tmp.signal = panget(c_lab);
            S{k} = tmp;
        end
        varargout{1} = S;
    else
        warning('MPAnSuiteWarning: an output is expected but it is empty since the list mem in the OPTIONS struct is empty');
        varargout{1} = [];
    end
end
