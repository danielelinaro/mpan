function MPanAlter(NAME, PARAM, VALUE, OPTIONS)
% MPanAlter can be used to modify one of the modifiable parameters of the
% currently loaded netlist. NAME is the identifier of the altering action.
%
% Usage: MPanAlter(NAME, PARAM, VALUE)
%        MPanAlter(NAME, PARAM, VALUE, OPTIONS)
%
% MPanAlter(NAME, PARAM, VALUE) can be used to change the value of a
% parameter PARAM that is found in the currently loaded netlist.
% Such a parameter is defined in the netlist file by the keyword
% parameters (in native PAN language) or .param (in SPICE native language).
% For instance one can find
%
% parameters Kvco = 2E6
%
% and with MPanAlter('MyAlter', 'Kvco', 1E5) the value of Kvco is altered.
% The change
% to the parameter is not done by overwriting the netlist file but it is
% an operation that is done in memory thus, if the netlist is dumped from
% memory and reloaded, one will find the original value of the parameter.
% When MPanAlter is used it effects any following analysis and all the
% netlist parameters depending on the modified one are apdated.
% For instance if
%
% parameters Kvco = 2E6 A = Kvco/2
%
% then, after using MPanAlter('MyAlter', 'Kvco', 1E5),
% one will have A = 0.5E5.
%
% MPanAlter(NAME, PARAM, VALUE, OPTIONS) The OPTIONS structure is used.
% It allows to alter not only a parameter
% defined by the keyword parameters, but also the value of a parameter of a
% certain device instance or model or a global options of the PAN circuit
% simulator. For instance, if the netlist contains
%
% Rin N1 N2 resistor r = 10
%
% it is possible to modify the resistance of Rin using the option
% instance = 'Rin', setting PARAM to 'r' and VALUE to 25. The option
% model allows to modify a parameter PARAM that is a parameter of device
% model ant its change affects all the devices that have been defined on
% the basis of such a model. For instance
%
% model RES resistor kf=1n af=1
% Rin1 N1 N2 RES r = 10 noisetype = 4
% Rin2 N1 N2 RES r = 10 noisetype = 4
%
% defines to resistor in parallel of model RES. They are noisy of flicker
% type and the flicker noise exponent af and coefficient kf are defined in
% the model RES. Using the option
% model = 'RES', setting PARAM to 'kf' and VALUE to 2, one changes the
% flicker noise coefficient of all the resistor of type RES.
% A further possibility is to modify an option PARAM of the simulator. This
% is done by using the option opt = true. For instance, if the netlist file
% contains
%
% options writeparams = yes digits = 12
%
% one can alter digits by using MPanAlter with option opt = true, PARAM set
% to 'digits' and VALUE to 8.
%
% In general, when a device parameter or a global simulation options is
% changed, the results computed by previous analyses (those that
% preceded the current NAME action) become invalid, that is, they
% cannot be futher used to start the following analyses. By using the
% option invalidate = false one forces the simulator (at his/her own risk!)
% to not invalidate the previous analyses results. It is important to
% notice that only the results in memory are invalidated and the RAW files
% generates by previous analysis are not deleted.
%
% See also
%    MPanAlterSetOptions
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/02/10$

global MPanSuite_NETLIST_INFO
if isempty(MPanSuite_NETLIST_INFO) || isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME)
    error('MPanSuiteError: a MPanSuiteNetlist is not loaded yet.')
end

if nargin < 3
    error('MPanSuiteError: at least 3 input arguments are required.')
end

str_command = [NAME ' alter param = "' PARAM '" value = ' num2str(VALUE,'%23.16e')];

if nargin == 4
    KeyNames = fieldnames(OPTIONS);
    m = numel(KeyNames);
    for k = 1:m
        key = KeyNames{k};
        if ~isempty(OPTIONS.(key))
            if ischar(OPTIONS.(key))
                if strcmp(key,'instance')
			str_command = [str_command ' ' key ' = ' OPTIONS.(key)]; %#ok<*AGROW>
		else
			str_command = [str_command ' ' key ' = "' OPTIONS.(key) '"']; %#ok<*AGROW>
		end
            else
                str_command = [str_command ' ' key ' = ' num2str(OPTIONS.(key),'%23.16e')];
            end
        end
    end
end

pansimc(str_command);
