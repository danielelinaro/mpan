function options = MPanAlterSetOptions(varargin)
%MPanAlterSetOptions creates an options structure for PAN ALTER analysis.
%
% Usage: OPTIONS = MPanTranSetOptionsShort('NAME1',VALUE1,'NAME2',VALUE2,...)
%        OPTIONS = MPanTranSetOptionsShort(OLDOPTIONS,'NAME1',VALUE1,...)
%
% OPTIONS = MPanAlterSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...) creates
% a PAN ALTER options structure OPTIONS in which the named properties have
% the specified values. Any unspecified properties have default values.
% Case is ignored for property names.
%
% OPTIONS = MPanTranSetOptionsShort(OLDOPTIONS,'NAME1',VALUE1,...)
% alters an existing options structure OLDOPTIONS.
%
% MPanAlterOptions with no input arguments displays all property names
% and their possible values.
%
% MPanAlterSetOptions properties
%
%  1 - instance [ String ]
%           This option is used to specify a specific device instance one
%           wants to alter a certain parameter. For instance, if the
%           currently loaded netlist contains
%
%           Rin N1 N2 resistor r = 10
%
%           it is possible to modify the resistance of Rin using the option
%           instance = 'Rin' and setting PARAM to 'r' and VALUE to 25. Thus
%           one has to write
%
%           myoptions = MPanAlterSetOptions('instance','Rin');
%           MPanAlter = MPanAlter('MyAlterNAME', 'r', 25, myoptions);
%
%  2 - model [ String ]
%           This option is used to specify a specific device model one
%           wants to alter a certain parameter. For instance, if the
%           currently loaded netlist contains
%
%           model RES resistor kf=1n af=1
%           Rin1 N1 N2 RES r = 10 noisetype = 4
%           Rin2 N1 N2 RES r = 10 noisetype = 4
%
%           writing
%
%           myoptions = MPanAlterSetOptions('model','RES');
%           MPanAlter = MPanAlter('MyAlterNAME', 'kf', 2, myoptions);
%
%           one changes the flicker noise coefficient of all the resistor
%           of type RES.
%
% 3  - opt [ {false} | true ]
%           if opt is set to true than the
%           MPanAlter(NAME, PARAM, VALUE, OPTIONS) analysis will alter
%           PARAM that is a global parameter of the PAN simulator.
%           For instance, if the netlist file contains
%
%           options writeparams = yes digits = 12
%
%           one can alter digits by writing
%
%           myoptions = MPanAlterSetOptions('opt',true);
%           MPanAlter = MPanAlter('MyAlterNAME', 'digits', 8, myoptions);
%
%  6 - annotate [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]
%           Degree of annotation. It is an integer number values
%           from 1 to 7. It turns on displaying of generic
%           informations about the analysis run.
%
%  7 - invalidate [ false | {true} ]
%           In general, when a device parameter or a global simulation
%           options is  changed, the results computed by previous analyses
%           (those that preceded the current alter stetement) become
%           invalid, that is, they cannot be further used to start the
%           following analyses. By using the option invalidate = false
%           one forces the simulator (at his/her own risk!)
%           to not invalidate the previous analyses results.
%           It is important to notice that only the results in memory are
%           invalidated and the RAW files generates by previous analysis
%           are not deleted.
%
% See also
%    MPanAlter
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/02/10$

if (nargin == 0) && (nargout ~= 0)
    error('If nargout ~= 0 nargin cannot be zero');
end

if (nargin ~= 0) && (nargout == 0)
    error('If narging ~= 0 nargout cannot be zero');
end

if (nargin ~= 0) && (nargout ~= 0)
    if isa(varargin{1},'struct') && (nargin == 1)
        error('If varargin{1} is a struct then nargin must be at least 3');
    end
end

% If called without input and output arguments, print out the possible keywords
if (nargin == 0) && (nargout == 0)
    fprintf('(6)  annotate        [ 0 | 1 | 2 | {3} | 4 | 5 | 6 | 7 ]\n');
    fprintf('(1)  instance        [ String ]\n');
    fprintf('(7)  invalidate      [ false | {true} ]\n');
    fprintf('(2)  model           [ String ]\n');
    fprintf('(3)  opt             [ {false} | true ]\n');
    return;
end

KeyNames = {
    'instance'
    'model'
    'opt'
    'annotate'
    'invalidate'};

options = MPanOptions(KeyNames,varargin{:});

