function varargout = MPanTran(NAME, TSTOP, OPTIONS)
% MPanTran runs a PAN transient analysis. A netlist must be already loaded
% with MPanNetLoad.
%
% Usage: MPanTran(NAME, TSTOP)
%        MPanTran(NAME, TSTOP, OPTIONS)
%        S = MPanTran(NAME, TSTOP, OPTIONS)
%
% MPanTran(NAME, TSTOP) runs a PAN transient analysis whose identifier is
% NAME. The simulation is perfomed from 0 to TSTOP. The default options are
% used.
%
% MPanTran(NAME, TSTOP, OPTIONS) runs a PAN transient analysis whose
% identifier is NAME. The simulation is perfomed from 0 (or tstart if
% specified in OPTIONS) to TSTOP. The OPTIONS structure is used.
%
% S = MPanTran(NAME, TSTOP, OPTIONS) works as the previous one
% but S is an output cell arrays and each cell contains
% a label and a waveform. The waveform are those specified with the mem
% field in OPTIONS. If mem is not specified S is empty.
%
% The PAN transient analysis computes the time domain behavior of linear
% and nonlinear circuits. The initial conditions are computed automatically
% through a DC analysis. Time domain
% integration employs different types of linear multi-step methods, such as
% trapezoidal and Gear methods. There are two different
% mechanisms to control the integration time step.
% Waveforms made available to control analysis are:
% 
% -) Node voltages and branch currents computed by transient analysis, time
% samples are stores in the 'time' vector. Waveforms can be accessed through the
% command MPanGet command
% 
% -) Results by time domain noise analysis can be retrived through the command
% 'get("TranName.node:noise")'. Results are computed on a regular time point
% grid. Time instants can be retrieved through the command
% 'get("TranName.time:noise")'. The large signal solution is saved on the same
% time mesh. These results can be retrieved through the command
% 'get("TranName.node:decimated")'.
% 
% -) When the parameter to compute the working period of a periodic circuit is
% turned on, these other results are available: 'period' the computed working
% period of the circuit; 'tstart' the starting time instance of a computed
% period; 'TSTOP' the last time instant of the computed period; 'samples' the
% index identifying the working period (x-axis of these results).
%
% See also
%    MPanTranSetOptionsShort,
%    MPanTranSetOptions
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/02/10$

global MPanSuite_NETLIST_INFO
if isempty(MPanSuite_NETLIST_INFO) || isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME)
    error('MPanSuiteError: a MPanSuiteNetlist is not loaded yet.')
end

if nargin < 2
    error('MPanSuiteError: at least 2 input arguments are required.')
end

if nargout > 2
     error('MPanSuiteError: no more than 2 outputs can be assigned')
end

str_command = [NAME ' tran tstop = ' num2str(TSTOP,'%23.16e')];

if nargin == 3
    KeyNames = fieldnames(OPTIONS);
    m = numel(KeyNames);
    for k = 1:m
        key = KeyNames{k};
        if ~isempty(OPTIONS.(key))
            if strcmp(key,'savelist') || strcmp(key,'mem')
                str_command = [str_command ' ' key ' = [']; %#ok<*AGROW>
                nrow = numel(OPTIONS.(key));
                for j = 1:nrow-1
                    str_command = [str_command '"' OPTIONS.(key){j} '",'];
                end
                str_command = [str_command '"' OPTIONS.(key){nrow} '"] '];
            else
                if ischar(OPTIONS.(key))
                    str_command = [str_command ' ' key ' = "' OPTIONS.(key) '"'];
                else
                    str_command = [str_command ' ' key ' = ' num2str(OPTIONS.(key),'%23.16e')];
                end
            end
        end
    end
end

pansimc(str_command);

MPanUpdateRawFilesList();
    
if nargout == 1
    if ~isempty(OPTIONS.mem)
        nmem = numel(OPTIONS.mem);
        S = cell(nmem,1);
        tmp = struct('label',[],'signal',[]);
        for k = 1:nmem
            tmp.label = OPTIONS.mem{k};
            c_lab = [NAME '.' OPTIONS.mem{k}];
            tmp.signal = panget(c_lab);
            S{k} = tmp;
        end
            varargout{1} = S;
        else
        warning('MPAnSuiteWarning: an output is expected but it is empty since the list mem in the OPTIONS struct is empty');
        varargout{1} = [];
    end
end

