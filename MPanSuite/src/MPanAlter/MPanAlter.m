function MPanAlter(NAME, PARAM, VALUE, varargin)
% MPanAlter can be used to modify one of the modifiable parameters of the
% currently loaded netlist. NAME is the identifier of the altering action.
%
% Usage: MPanAlter(NAME, PARAM, VALUE)
%        MPanAlter(NAME, PARAM, VALUE, varargin)
%
% MPanAlter(NAME, PARAM, VALUE) can be used to change the value of a
% parameter PARAM that is found in the currently loaded netlist.
% Such a parameter is defined in the netlist file by the keyword
% parameters (in native PAN language) or .param (in SPICE native language).
%
% MPanAlter(NAME, PARAM, VALUE, varargin). It is thus possible to use
% options for the MPanAlter function.
% varargin must be a sequence of pairs as 'NAME1',VALUE1,'NAME2',VALUE2,...
% where the name of the options and the allowed values are specified by the
% PAN simulator documentation.
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2015.
% Revision: 2.0 $Date: 2022/03/10$

% global MPanSuite_NETLIST_INFO
% if isempty(MPanSuite_NETLIST_INFO) || isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME)
%     error('MPanSuiteError: a MPanSuiteNetlist is not loaded yet.')
% end

if nargin < 3
    error('MPanSuiteError: at least 3 input arguments are required.')
end


str_command = [NAME ' alter param = "' PARAM '" value = ' num2str(VALUE,'%23.16e')];


if nargin > 4
    str_command = MPanStrCommandComplete(str_command,varargin{:});
end

clear NAME PARAM VALUE varargin;

pansimc(str_command);
