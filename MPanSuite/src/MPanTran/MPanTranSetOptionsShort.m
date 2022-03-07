function options = MPanTranSetOptionsShort(varargin)
%MPanTranSetOptionsShort creates an options structure for PAN TRAN analysis.
%
% Usage: OPTIONS = MPanTranSetOptionsShort('NAME1',VALUE1,'NAME2',VALUE2,...)
%        OPTIONS = MPanTranSetOptionsShort(OLDOPTIONS,'NAME1',VALUE1,...)
%
% OPTIONS = MPanTranSetOptionsShort('NAME1',VALUE1,'NAME2',VALUE2,...) creates
% a PAN TRAN options structure OPTIONS in which the named properties have
% the specified values. Any unspecified properties have default values.
% It is sufficient to type only the leading characters that uniquely
% identify the property. Case is ignored for property names.
%
% OPTIONS = MPanTranSetOptionsShort(OLDOPTIONS,'NAME1',VALUE1,...) alters an
% existing options structure OLDOPTIONS.
%
% MPanTranOptionsShort with no input arguments displays all property names
% and their possible values.
%
% MPanTranSetOptionsShort properties
%
%  1 - annotate [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]
%           Degree of annotation. It is an integer number values
%           from 1 to 7. It turns on displaying of generic
%           informations about the analysis run.
%
%  5 - maxiter [integer | {10} ]
%           maximum allowed number of Newton
%           iterations at each time step of the time domain
%           analysis. The Newton algorithm is considered as non
%           converging when the iteration number goes above the
%           'maxiter' value. In this case the integration time
%           step is shortened and the Newton algorithm is restarted.
%
% 10 - savelist [ list ]
%           It defines a list of nodes or branch currents that
%           will be saved into the output file during simulation.
%           Example: ['x';'y'] -> saves voltages at nodes x and y
%           It is mandatory to use define savelist as a column vector, thus
%           using ; as a separator between strings.
%           Other computed electrical variables are not saved.
%
% 11 - devvars [ {false} | true ]
%           some device variables, such as for example
%           the drain current of mosfets, the anode-cathode
%           current of diodes and currents through capacitors are
%           stored in the simulation output file.
%
% 15 - decimation [ real ]
%           if greater than 0 this parameter turns on
%           the decimation of the time points at which the
%           computed solution is saved in the output file. A
%           dedicated <raw> file in created with the suffix
%           <decimated> and the decimated output is stored in
%           this file. The value of this parameter sets the fixed
%           time interval used to build the even mesh of time
%           points in the decimated output.
%
% 16 - rawmode [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]
%           overns how results are saved in the output rawfiles.
%           Possible choices are:
%
%           0: results are not saved;
%           1: all types of results are saved;
%           2: only decimated results are saved;
%           3: only time noise results are saved;
%           4: only device current results are saved;
%           5: only vector field results when jumps are involved are saved.
%           6: only time domain results are saved.
%
%           Decimated results are computed only if decimation is
%           turned on. Time noise analysis is performed only if it
%           is turned on. The term 'time domain' means
%           results from the conventional time domain analysis
%           (i.e not decimated and time domain noise ones). Note
%           that eventhough no results are saved they can be made
%           available in memory. See the mem options.
%
% 18 - supernode [ {false} | true ]
%           introduce custsets formed by
%           independent voltage sources. These cutsets are known
%           as 'super-nodes'. Super-nodes avoid to add the
%           current through the independent voltage source among
%           the unkowns of the problem and thus reduce the size
%           of the problem increasing efficiency.
%
% 21 - method [ {1} | 2 ]
%           Select the integration method:
%           1 trapezoidal;
%           2 Gear method of various order.
%
% 22 - maxord [ 1 | {2} | 3 | 4 | 5 | 6 ]
%           Set the maximum order of the Gear integration method
%           It has no meaning if other integration methods are employed
%
% 23 - acntrl [ 1 | {2} ]
%           select the accuracy control method:
%           1: relative energy balance. This method computes the
%           electrical energy variation of each capacitor and
%           inductor along each integration interval and the
%           corresponding electrical work delivered by the
%           resistive one-port elements to which they are
%           connected. The electrical work and energy are
%           compared and the integration time step is chosen in
%           order to keep their difference below the user defined
%           threshold;
%           2: absolute energy balance. This method is identical
%           to the previous one, but the difference between the
%           electrical work and energy is compared to the total
%           energy stored into the corresponding
%           capacitor/inductor. The integration time step is
%           chosen to keep variation with respect to total stored
%           energy below the user defined threshold. In general
%           this method gives less accurate results with respect
%           to the previous one, but the analysis runs faster.
%
% 24 - ntoltype [ 1 | {2} | 3]
%           this option specifies the tolerance
%           check adopted at each time point of the analysis to
%           control if the Newton method has reached convergence.
%           Checks are done both on the variation of variables
%           computed by the Newton method and on the entries of
%           the right hand side vector. Define as 'dX(n)' the
%           variation of the 'n' electrical variable, as 'reltol'
%           and 'abstol' the relative and absolute maximum
%           allowed variations, respectively. The n-th variable
%           has converged if '| dX(n) | < reltol * Y(n) +
%           abstol'. The 'ntoltype' parameter defines three
%           different ways to compute 'Y(n)', number as 1, 2 and
%           3. Their meanings are listed in the following:
%
%           1 : global. 'Y(n)' is defined as the maximum over the
%           time interval, till the current time point, of the
%           maximum value assumed by the 'X(n)' electrical
%           variables, where 'n' varies from 1 to N, being N the
%           number of circuit variables. Note that in this case
%           'Y(n)' is unique value adopted for all the 'dX(n)'
%           variable variations.
%
%           2 : local. 'Y(n)' is defined as the maximum absolute
%           value of 'X(n)' in the time interval till the current
%           time point. Note that in this case 'Y(n)' is
%           different for each electrical variable.
%
%           3 : point local. 'Y(n) = | X(n) |'.
%
%           The convergence check tightens as 'ntoltype' is
%           increased.
%
% 26 - skipdc [ {false} | true ]
%           the initial DC analysis performed to
%           determine the initial conditions is skipped. This can
%           help when dealing with critical circuits that cause
%           failures of the DC analysis. In this case voltages
%           across capacitors and current through inductors are
%           assumed null.
%
% 27 - uic [ {0} | 1 | 2 ]
%           if > 0 use given initial conditions of
%           inductors and capacitors. Initial conditions are
%           considered in two different ways according to the
%           value of this paramenter; in particular:
%
%           1: it is assumed that all the capacitors and
%           inductors have suitable initial conditions. This
%           means that if they are not specified by the user,
%           they are assumed equal to zero. Note that this
%           initial condition determination fails when there are
%           loops of voltages source and capacitors even though
%           consistent initial conditions are given, since the
%           loop current is undertermined. The same applies to
%           inductor cut-sets.
%
%           2: it is assumed that all the capacitors and
%           inductors whose initial conditions have not been
%           specified are open circuit and short circuit,
%           respectively.
%
% 28 - restart [ false | {true} ]
%           restart the analysis, that is, do not
%           use results computed by a previous transient,
%           envelope or shooting analysis as initial condition
%           for the current transient analysis.
%
% 29 - save [ String ]
%           the path of the file into which the
%           solution is saved (bz2 format is adopted).
%           Example: "./example/sim/test.xxx"
%           The solution stored in this file can be later loaded by
%           the simulator and used as initial condition from
%           which the transient algorithm is started.
%
% 30 - load  [ String ]
%           the path of the file from which a
%           previously saved solution is read. The file format
%           can be both ascii and bz2 and it is automatically
%           Example: "./example/sim/test.xxx"
%           determined during loading. This solution is used as
%           initial condition to the transient algorithm.
%
% 31 - mem  [ list ]
%           results that have to be saved in memory.
%           These results can be later accessed from the body of
%           the <control> analysis through the <get> function.
%           In the same way they can be accessed from Matlab command line
%           see MPanGet.m
%           Note that the saving of results in memory can require
%           and occupy a large amount of memory.
%
% 34 - tmin [ real ]
%           minimum allowed time step length. The value
%           of this parameter is automatically determined by the
%           simulator if it is not specified by the user.
%
% 35 - tmax [ real ]
%           maximum allowed time step. The value of this parameter is
%           automatically determined by the simulator if it is
%           not specified by the user.
%
% 39 - savetime [ real ]
%           results are saved in the output file when
%           simulation time is greater than the value of this
%           parameter. This parameter can be useful to reduce the
%           amount of results saved in the output file.
%
% 40 - tstart [ real ]
%           time instance at which the transient analysis begins.
%
% 43 - trabstol [ real | {1.0e-12} ]
%           absolute convergence tolerance for
%           capacitor voltages and inductor currents.
%
% 44 - trreltol [ real | {1.0e-3} ]
%           relative convergence tolerance for
%           capacitor voltages and inductor currents
%
% 45 - vabstol  [ real | {1.0e-6} ]
%           Absolute voltage tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis
%
% 46 - vreltol  [ real | {1.0e-6} ]
%           Relative voltage tolerance employed by the Newton
%           algorithm at each time point of the time domain
%           analysis
%
% 47 - iabstol [ real | {1.0e-12} ]
%           Absolute current tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis
%
% 48 - ireltol [ real | {1.0e-6} ]
%           Relative current tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis
%
% 56 - damping [ {false} | true ]
%           apply a version of the damped Newton
%           method.
%
% 61 - skip [ 0 | {1} | 2 ]
%           skip time point (advance in time) in
%           case of unrecoverable convergence failures of the
%           Newton algorithm. It helps to continue and
%           successfully terminate the simulation even though
%           accuracy can be locally compromised. Possible choises
%           of this parameter are:
%
%           0: no skipping is applyied in case there is no
%           convergence of the Newton algorithms;
%
%           1: skipping is applyed but only if there is
%           convergence of the Newton algorithm in the new time
%           point, determined after the forward time skipping.
%
%           2: forward time skipping is applyed anyway, even
%           though there is no convergence of the Newton
%           algorithm in the new time point.
%
% 75 - findperiod [ {false} | true ]
%           find period values during the tran
%           analysis. This can be used to monitor synchronization
%           transients. Unconsistent results are possibly found
%           if a nonperiodic dynamics is present. Period doubling
%           may also cause problems.
%
% 79 - jump [ {false} | true ]
%           activate finding of discontinuities
%           in the vector field. This option has meaning only
%           when the fundamental matrix is computed. Saltation
%           matrices are exploited to construct a correct
%           fudamental matrix of circuits characterised by
%           discontinuities in the vector field. Discontinuities
%           in the vector field can be also introduced by sharp
%           varying functions modeling circuit elements, such as
%           for example the 'y=tanh(a*x)' function with the 'a'
%           gain too large. The solver automatically determines
%           possible discontinuities due to numerical problems
%           introduced by too sharp nonlinear functions and
%           automatically introduce 'saltation' matrices. The
%           solver introduces also 'saltation' matrices due to
%           dscontinuities caused by commutations of pseudo
%           analog-to-digital and digital-to-analog converters
%           during simulations of mixed digital/analog circuits
%           and due to behavioural elements tagged as digital.
%
% 84 - noiseinj  [ {1} | 2 ]
%           specifies how noise is handled by the
%           solver. Possible choices are:
%           1: noise is injected only in the equivalent
%           variational model of the circuit.
%           2: noise is injected only in the (nonlinear) circuit
%           and affects exclusively the large signal solution.
%
% 85 - noisefmax [ real ]
%           maximum frequency considered in simulating
%           time domain noise effects. The time domain noise
%           analysis is automatically turned on by specifying
%           this parameter.
%
% 86 - seed [ integer ]
%           the seed of the random number generators
%           used in the time domain noise analysis. If not
%           specified the seed is taken from the system clock.
%
%
% See also
%    MPanGet, MPanTranSetOptions,
%    MPanTran

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
    fprintf('(23) acntrl          [ 1 | {2} ]\n');
    fprintf('(1)  annotate        [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]\n');
    fprintf('(56) damping         [ {false} | true ]\n');
    fprintf('(15) decimation      [ real ]\n');
    fprintf('(11) devcurr         [ {false} | true ]\n');
    fprintf('(75) findperiod      [ real ]\n');
    fprintf('(47) iabstol         [ real | {1.0e-12} ]\n');
    fprintf('(48) ireltol         [ real | {1.0e-6}\n');
    fprintf('(79) jump            [ {false} | true ]\n');
    fprintf('(30) load            [ String ]\n');
    fprintf('(5)  maxiter         [ integer | {10} ]\n');
    fprintf('(31) mem             [ list ]\n');
    fprintf('(21) method          [ {1} | 2 ]\n');
    fprintf('(85) noisefmax       [ real ]\n');
    fprintf('(84) noiseinj        [ {1} | 2 ]\n');
    fprintf('(24) ntoltype        [ 1 | {2} | 3]\n');
    fprintf('(22) maxord          [ 1 | {2} | 3 | 4 | 5 | 6 ]\n');
    fprintf('(16) rawmode         [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]\n');
    fprintf('(28) restart         [ false | {true} ]\n');
    fprintf('(29) save            [ String ]\n');
    fprintf('(10) savelist        [ list ]\n');
    fprintf('(39) savetime        [ real ]\n');
    fprintf('(86) seed            [ integer ]\n');
    fprintf('(26) skipdc          [ {false} | true ]\n');
    fprintf('(18) supernode       [ {false} | true ]\n');
    fprintf('(35) tmax            [ real ]\n');
    fprintf('(34) tmin            [ real ]\n');
    fprintf('(43) trabstol        [ real | {1.0e-12} ]\n');
    fprintf('(44) trreltol        [ real | {1.0e-3} ]\n');
    fprintf('(40) tstart          [ real | {1.0e-6} ]\n');
    fprintf('(42) tstop           [ real | {1.0e-6} ]\n');
    fprintf('(27) uic             [ {0} | 1 | 2 ]\n');
    fprintf('(45) vabstol         [ real | {1.0e-6} ]\n');
    fprintf('(46) vreltol         [ real | {1.0e-6} ]\n');
    return;
end

KeyNames = {
    'acntrl'
    'annotate'
    'damping'
    'decimation'
    'devvars'
    'findperiod'
    'iabstol'
    'ireltol'
    'jump'
    'load'
    'maxiter'
    'mem'
    'method'
    'noisefmax'
    'noiseinj'
    'ntoltype'
    'maxord'
    'rawmode'
    'restart'
    'save'
    'savelist'
    'savetime'
    'seed'
    'skipdc'
    'supernode'
    'tmax'
    'tmin'
    'trabstol'
    'trreltol'
    'tstart'
    'tstop'
    'uic'
    'vabstol'
    'vreltol'};

options = MPanOptions(KeyNames,varargin{:});

