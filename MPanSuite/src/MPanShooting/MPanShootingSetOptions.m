function options = MPanShootingSetOptions(varargin)
%MPanShootingSetOptions creates an options structure for PAN SHOOTING analysis.
%
% Usage: OPTIONS = MPanShootingSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...)
%        OPTIONS = MPanShootingSetOptions(OLDOPTIONS,'NAME1',VALUE1,...)
%                  MPanShootingSetOptions()
%
% OPTIONS = MPanShootingSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...) creates
% a PAN SHOOTING options structure OPTIONS in which the named properties have
% the specified values. Any unspecified properties have default values.
% It is sufficient to type only the leading characters that uniquely
% identify the property. Case is ignored for property names.
%
% OPTIONS = MPanShootingSetOptions(OLDOPTIONS,'NAME1',VALUE1,...) alters an
% existing options structure OLDOPTIONS.
%
% MPanShootingSetOptions with no input arguments displays all property names
% and their possible values.
%
%MPanShootingSetOptions properties
%(See also the PAN Userguide ... )
%
%  1 - annotate [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]
%           Degree of annotation. It is an integer number from 1
%           to 7 that turns on displaying of generic information
%           about the analysis run. Values above 7 are bitwise
%           and turn on specific printouts. In particular:
%
%           0x08: print sensitivity matrix and RHS at various
%           phases of the shooting analysis.
%
%           0x10: at convergence of the shooting method the
%           fundamental matrix is saved in a file named as the
%           analysis, if available. For example the fundamental
%           matrix is available if a Floquet analysis is issued.
%    
%           0x20: give a short report on actions performed to
%           find saltation matrices.
%
%  2 - maxiters [ integer | {100} ]
%           Maximum allowed iterations for the shooting algorithm.
%
%  3 - restart [ false | {true} ]
%           Restart the shooting analysis, that
%           is, do not use previous results computed by a
%           transient analysis, an envelope analysis or a
%           shooting analysis as initial guess to the current
%           shooting analysis. If the circuit is autonomous the
%           period computed by one of the previous analyses is
%           adopted as initial guess. If the circuit is
%           non-autonomous and the <"period"> parameter has not
%           been specified the period specified or computed by
%           the previous analyses is adopted.
%
%  4 - printnodes [ {false} | true ]
%           Print external/internal node names-index map.
%           This parameter serves mainly for debug purposes.
%
%  5 - printsh [ {false} | true ]
%           When true the solution obtained at
%           convergence of the shooting method is printed.
%
%  6 - savelist [ list ]
%           It defines a list of nodes or branch currents that
%           will be saved into the output file during simulation.
%           Example: ['x';'y'] -> saves voltages at nodes x and y
%           It is mandatory to use define savelist as a column vector, thus
%           using ; as a separator between strings.
%           Other computed electrical variables are not saved.
%
%  7 - thermalnet [ {false} | true ]
%           Use the thermal network.
%
%  8 - powernet [ {false} | true ]
%           Turns on/off the use of power network.
%
%
%  9 - checkstrange [ {false} | true ]
%           Boolean: check if there are some `strange
%           behaviours' of devices. For example, it is checked if
%           bulk-drain and bulk-source parasitic diodes of
%           mosfets are forward biased. This check slows down a
%           bit the simulation and can generate a large number of
%           warnings.
% 10 - autonomous [ {false} | true ]
%           It tells if the circuit is autonomous.
%           In this case the working period of the circuit is
%           automatically estimated.
%
%*11 - vprobe [ list ]
%           The list containing the pair of nodes at
%           which the voltage probe is connected. If the second
%           node of the list is omitted, it is considered
%           connected to ground. The format is ['pos';'neg']
%           It is mandatory to use define vprobe as a column vector, thus
%           using ; as a separator between strings.
%
% 12 - probeharm [ integer | {1} ]
%           The index of the harmonic at which the probe drives the circuit.
%                          
% 13 - vprobemax [ real ]
%           The maximum value of the magnitude of the voltage probe
%           employed during the sweep to find the steady state solution.
%
% 14 - vprobemag [ real | {0.0} ]
%           The magnitude of the voltage probe.
%
% 15 - vprobestop [ false | {true} ]
%           Stop vprobe sweeping till its given
%           maximum value when a solution is found.
%                          
% 16 - vprobemaxdelta [ real ]
%           The maximum delta voltage applied during
%           sweeping of the voltage probe magnitude. This value
%           is automatically determined if not given. It must be
%           less than the maximum allowed probe magnitude.
%
% 17 - eabstol [ real | {1.0e-6} ]
%           Absolute tolerance employed by the
%           shooting analysis to check convergence.
%
% 18 - ereltol [ real | {1.0e-4} ]
%           Relative tolerance employed by the
%           shooting analysis to check convergence.
% 19 - iabstol [ real | {1.0e-12} ]
%           Absolute current tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis.
%
% 20 - ireltol [ real | {1.0e-6} ]
%           Relative current tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis.
%
% 21 - vabstol  [ real | {1.0e-6} ]
%           Absolute voltage tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis.
%
% 22 - vreltol  [ real | {1.0e-6} ]
%           Relative voltage tolerance employed by the Newton
%           algorithm at each time point of the time domain analysis.
%
% 23 - trabstol [ real | {1.0e-12} ]
%           Absolute convergence tolerance for
%           capacitor voltages and inductor currents.
%
% 24 - trreltol [ real | {1.0e-3} ]
%           Relative convergence tolerance for
%           capacitor voltages and inductor currents
%
% 25 - ntoltype [ 1 | {2} | 3 ]
%           This option specifies the tolerance
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
% 26 - acntrl [ {1} | 2 ]
%           Select the accuracy control method:
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
% 27 - skip [ 0 | {1} | 2 ]
%           Skip time point (advance in time) in
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
% 28 - cmin [ {false} | true ]
%           If true parasitic capacitors of
%           suitable values are inserted between each circuit
%           node and ground when the simulator is in trouble to
%           compute the solution. This can aid integration
%           algorithms. However attention must be payed since
%           insertion of these capacitors can yield some circuits
%           to oscillate or even to become unstable!
%
% 29 - maxdeltav [ real | {??} ]
%           The maximum allowed variation of node
%           voltage allowed during the iterations of the Newton
%           algorithm. This should aid convergence and avoid
%           possible overflow.
%
% 30 - pseudotransient [ false | {true} ]
%           turn on/off the pseudo-transient
%           continuation algorithm. It acts as "fall-back" method
%           only when the conventional transient analysis could
%           fail.
%
% 31 - jump [ {false} | true ]
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
% 32 - jumpabstol [ real | {1.0e-6} ]
%           Absolute tolerance employed to
%           determine possible jumps in the  vector field
%           (current through capacitors and voltage across inductors).
%                          
% 33 - jumpreltol [ real | {1.0e-3} ]
%           Relative tolerance employed to
%           determine possible jumps in the vector field (current
%           through capacitors and voltage across inductors).
%
% 34 - floquet [ integer | {0} ]
%           The Floquet multipliers related to the
%           state transition matrix computed at convergence of
%           the shooting method are evaluated. Possible values of
%           this parameter are:
%           1 : the Floquet multipliers are shown after
%           convergence of the shooting algorithm;
%           2 : the Floquet multipliers are shown at each
%           iteration of the shooting algorithm.
%
% 35 - printeig [ {false} | true ]
%           Print the left and right eigenvectors of the monodromy matrix.
%
% 36 - eigf [ {false} | true ]
%           The periodic eigenfunctions of the
%           Floquet analysis are computed. In particular the
%           uj(t) and vj(t) eigenfunctions related to the
%           pseudo-state variables of the MNA formulation are
%           computed. Furthermore the vjB(t) functions that
%           relate possible small signal perturbations applied to
%           the circuit nodes to the pseudo-state variables and
%           the Muj(t) eigenfunctions that relate the
%           pseudo-state variables to the node potentials and
%           device branch currents (of those elements that are
%           not voltage controlled) are also computed.
%
% 37 - samples [ integer | {200} ]
%           The number of samples used to compute
%           the sensitivity functions (Floquet eigenfunctions)
%           with respect to pseudo-state variables along one
%           working period of the circuit. Floquet eigenfuncitons
%           are computed in a reduced number of time points with
%           respect to those used by the variable time step
%           length integration algorithms employed by the time
%           domain analysis. This is done mainly to reduce the
%           total ammount of memory needed to store and elaborate
%           the results. The minimum allowed number of samples is
%           equal to 100.
%                          
% 38 - printmo [ {false} | true ]
%           When true the fundamental matrix is
%           printer. In case of autonomous circuits the
%           fundamental matrix is bordered with an extra column
%           and an extra row that refer to the of the solution
%           with respect to the working period of the circuit.
%                          
% 39 - fmnumber [ integer | {32766} ]
%           The maximum number of the Floquet
%           multipliers that are considered for computing the
%           u(t) and v(t) eigenfunctions. Floquet multipliers are
%           ordered from the largest towards the smallest, the
%           first <fmnumber> are considered.
%
% 40 - devvars [ {false} | true ]
%           The currents of devices, for example
%           the drain current of mosfets, the anode-cathode
%           current of diodes and currents through capacitors are
%           stored in the simulation output file (of the Floquet analysis).
%
% 41 - eigfnorm [ {false} | true ]
%           Normalise the Floquet
%           eigenfunctions. Each eigenfunction is rescaled by the
%           corresponding Floquet exponent; this results in a
%           periodic function. Note that largely dumped or
%           increasing eigenfunction must be multiplied by
%           relatively large or small scaling factors mainly at
%           the end of the period and this can lead to
%           amplification of truncation errors. The result is
%           that the Floquet eigenfunction is no longer periodic
%           since truncation errors sum up in an umpredictable way
%           to the correct Floquet eigenfunction.
%
% 42 - fft  [ {false} | true ]
%           It turns on the computation of Fourier
%           series coefficients of the electrical variables. The
%           value of the fundamental frequency is derived from
%           the working period of the circuit that is that given
%           by the user in the non-autnomous case or that
%           computed by the shooting algorithm in the autonomous case.
%
% 43  fftharms [ integer | {4} ]
%           The number of harmonics computed by FFT.
%
% 44  fftsamples [ integer | {??} ]
%           The number of sampling points adopted to compute the
%           coefficients of the Fourier series. It is ensured
%           that at least the specified number of points are used
%           but more points can be employed. The coefficients are
%           computed by evaluating the Fourier integrals and not
%           by applying the FFT algorithm. This ensures better
%           results even though few coefficients are computed.
%           This parameters is effective only if it specifies a
%           number of samples greater than `4 * <ffthars> + 1',
%           which represents the minimum allowed number of
%           employed samples.
%
% 45 - method [ {1} | 2 ]
%           Select the integration method:
%           1 trapezoidal;
%           2 Gear method of various order. 
%
% 46 - maxord [ 1 | {2} | 3 | 4 | 5 | 6 ]
%           Set the maximum order of the Gear integration method
%           It has no meaning if other integration methods are employed.
%
% 47 - minper [real | {??}]
%           Set the minimum value assumed by the estimated
%           circuit working period. This parameter has meaning
%           only if the <autonomous> parameter is set to true.
%
% 48 - uic [ {0} | 1 | 2 ]
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
% 51 - freltol [ real | {1.0e-4} ]
%           Relative tolerance employed by the
%           shooting analysis to check convergence in determining
%           the working frequency of autonomous circuits.
%
% 52 - saman [ {false} | true ]
%          Turns on/off the samanskii method. At
%          each iteration of the shooting method the sensitivity
%          matrix of electrical variables at the end of the
%          shooting interval with respect to the initial
%          conditions at the beginning of the interval is
%          computed. Even though it is a by product of the
%          transient analysis, at each time point a matrix by
%          matrix product is needed and it costs CPU time mainly
%          when a large number of electrical variables are
%          involved. At each iteration of the shooting method
%          the norm of the residue is monitored; when it
%          monotonically decreases of a relative factor lower
%          than 0.9 the computation of the sensitivity matrix is
%          suspended; at each subsequent iteration of the
%          shooting method the same previous sensitivity matrix
%          is adopted. This leads to an approximate Newton
%          iteration, but it saves CPU time even though, in
%          general, a larger number of transient analyses are
%          needed.
%
% 53 - damping [ real | {1.0} ]
%          The initial value of the damping factor
%          employed by the Newton algorithm to update the new
%          initial conditions. Normally at the beginning the
%          Newton iterations are undamped, for particular
%          circuit it can be useful to start with damped
%          iterations in order to aid and speed up convergence.
%
% 54 - statevars [ list ]
%           It is a list of names of device instances (for
%           example capacitors and inductors) that specify state
%           variables. These state variables are monitored by the
%           procedure that determines the working period of the
%           autonomous circuit. If this list is not given all
%           state variables are monitored
%           Example: ['C0';'L1'] -> select device instances labelled as C0
%           and L1.
%           It is mandatory to use define statevars as a column vector, thus
%           using ; as a separator between strings.
%                          
% 55 - parmo [ {false} | true ]
%           Turn on/off the use of multiple threads in computing
%           the monodromy matrix. .............  40
%
% 56 - tmin [ real ]
%           minimum allowed time step length. The value
%           of this parameter is automatically determined by the
%           simulator if it is not specified by the user.
%
% 57 - tmax [ real ]
%           maximum allowed time step. The value of this parameter is
%           automatically determined by the simulator if it is
%           not specified by the user.
%
% 58 - tinc  [ real | {1.1} ]
%           lengthening factor of the time step at convergence.
%
% 59 - timepoints [ Vector ]
%           the list containing the increasing time instants that
%           should be employed by the simulator during the
%           analysis.
%           Example: [1e-6 2e-6 3.5e-5]
%           It is not ensured that these time instants
%           are effectively met. However during the analysis
%           these time instants are considered and the
%           integration time step selection algorithm tries to
%           meet these points.
%
% 60 - forcetps [ {false} | true ]
%           force the use of the time points
%           speficied through the <"timepoints"> parameter. Note
%           that since the simulator can not automatically choose
%           the integration time step length when accuracy checks
%           on the found solution such as the local truncation
%           one are not satisfies the inaccuracies reflect in the
%           solution.
%
% 61 - solver [ {0} | 1 | 2 | 3]
%           The employed solver; available ones are:
%                          
%           0 : direct solver based on the Newton method and the
%           LU factorisation of the fundamental matrix;
%
%           1 : direct solver based on the Newton method and the
%           QR factorisation of the fundamental matrix.
%
%           2 : direct solver based on hybrid-Newton method.
%              
%           3 : iterative solver based on the Newton method and
%           the 'gmres' method.
%              
%           As simple guidelines to choose a solver one has to
%           consider that in general direct solvers are
%           faster on small and medium size circuits, the
%           iterative solver largely outperformes the direct ones
%           on large circuits. Circuits with more than a thousand
%           nodes are considered as large; in this case the
%           iterative solver is automatically chosen if this
%           option is not specified, that is, if a solver is not
%           directly specified by the user through this option.
%           The iterative solver requires tens time less memory
%           than direct solvers. If direct solvers are chosen
%           they take a smaller amount of memory if the Gear
%           integration method is employed. The QR factorisation
%           method of the fundamental matrix is preferred to the
%           LU one, since there are stiff circuits where some
%           pseudo-state variables yield Floquet multipliers
%           extremely close to 1. These Floquet multipliers
%           indicate that the fundamental matrix is singular.
%           Singularities can be handled by QR factorisation,
%           since the columns of the Q matrix can span the
%           subspace into which the solution `lives'. If in these
%           cases the LU factorisation method is chosen there are
%           convergence difficulties of the shooting method since
%           the residue can not be suitably reduced.
%                          
%           2 : iterative solver based on hybrid Newton and
%           'saltation' matrices. It is suited to the computation
%           of the steady state solution of problems where
%           electrical variables shows discontinuities of the
%           first kind. Note that mixed analog/digital circuits
%           fall in this class.
%
% 62 - save [ string ]
%           the path of the file into which the
%           solution is saved (bz2 format is adopted).
%           Example: "./example/sim/test.xxx"
%           The solution stored in this file can be later loaded by
%           the simulator and used as initial condition from
%           which the transient algorithm is started.
%
% 63 - load [ String ]
%           the path of the file from which a
%           previously saved solution is read. The file format
%           can be both ascii and bz2 and it is automatically
%           Example: "./example/sim/test.xxx"
%           determined during loading. This solution is used as
%           initial condition to the transient algorithm.
%
% 64 - mem  [ list ]
%           results that have to be saved in memory.
%           These results can be later accessed from the body of
%           the <control> analysis through the <get> function.
%           In the same way they can be accessed from Matlab command line
%           see MPanGet.m
%           Note that the saving of results in memory can require
%           and occupy a large amount of memory.                          
%
%NOTES:
%
% See also
%    MPanGet, MPanGet,
%    MPanGet, MPanGet,
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/04/10$

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
      fprintf('(26) acntrl          [ {1} | 2 ]\n');
      fprintf('(1)  annotate        [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]\n');
      fprintf('(10) autonomous      [ {false} | true ]\n');
      fprintf('(9)  checkstrange    [ {false} | true ]    \n');
      fprintf('(28) cmin            [ {false} | true ]\n');
      fprintf('(53) damping         [ real | {1.0} ]\n');
      fprintf('(40) devvars         [ {false} | true ]\n');
      fprintf('(17) eabstol         [ real | {1.0e-6} ]\n');
      fprintf('(36) eigf            [ {false} | true ]\n');
      fprintf('(41) eigfnorm        [ {false} | true ]\n');
      fprintf('(18) ereltol         [ real | {1.0e-4} ]\n');
      fprintf('(42) fft             [ {false} | true ]\n');
      fprintf('(43) fftharms        [ integer | {4} ]\n');
      fprintf('(44) fftsamples      [ integer | {??} ]\n');
      fprintf('(34) floquet         [ integer | {0} ]\n');
      fprintf('(39) fmnumber        [ integer | {32766} ]\n');
      fprintf('(60) forcetps        [ {false} | true ]\n');
      fprintf('(51) freltol         [ real | {1.0e-4} ]\n');
      fprintf('(19) iabstol         [ real | {1.0e-12} ]\n');
      fprintf('(20) ireltol         [ real | {1.0e-6} ]\n');
      fprintf('(31) jump            [ {false} | true ]\n');
      fprintf('(32) jumpabstol      [ real | {1.0e-6} ]\n');
      fprintf('(33) jumpreltol      [ real | {1.0e-3} ]\n');
      fprintf('(63) load            [ string ]\n');
      fprintf('(29) maxdeltav       [ real | {??} ]\n');
      fprintf('(2)  maxiters        [ integer | {100} ]\n');
      fprintf('(64) mem             [ list ]\n');
      fprintf('(45) method          [ {1} | 2 ]\n');
      fprintf('(47) minper          [real | {??}]\n');
      fprintf('(25) ntoltype        [ 1 | {2} | 3 ]\n');
      fprintf('(46) maxord          [ 1 | {2} | 3 | 4 | 5 | 6 ]\n');
      fprintf('(55) parmo           [ {false} | true ]\n');
      fprintf('(8)  powernet        [ {false} | true ]\n');
      fprintf('(35) printeig        [ {false} | true ]\n');
      fprintf('(38) printmo         [ {false} | true ]\n');
      fprintf('(4)  printnodes      [ {false} | true ]\n');
      fprintf('(5)  printsh         [ {false} | true ]\n');
      fprintf('(12) probeharm       [ integer | {1} ]\n');
      fprintf('(30) pseudotransient [ false | {true} ]\n');
      fprintf('(3)  restart         [ false | {true} ]\n');
      fprintf('(52) saman           [ {false} | true ]\n');
      fprintf('(37) samples         [ integer | {200} ]\n');
      fprintf('(62) save            [ string ]\n');
      fprintf('(6)  savelist        [ list ]\n');
      fprintf('(27) skip            [ 0 | {1} | 2 ]\n');
      fprintf('(61) solver          [ {0} | 1 | 2 | 3]\n');
      fprintf('(54) statevars       [ list ]\n');
      fprintf('(7)  thermalnet      [ {false} | true ]\n');
      fprintf('(59) timepoints      [ Vector ]\n');
      fprintf('(56) tinc            [ real ]\n');
      fprintf('(57) tmax            [ real ]\n');
      fprintf('(58) tmin            [ real ]\n');
      fprintf('(23) trabstol        [ real | {1.0e-12} ]\n');
      fprintf('(24) trreltol        [ real | {1.0e-3} ]\n');
      fprintf('(48) uic             [ {0} | 1 | 2 ]\n');
      fprintf('(21) vabstol         [ real | {1.0e-6} ]\n');
      fprintf('(11) vprobe          [ list ]\n');
      fprintf('(14) vprobemag       [ real | {0.0} ]\n');
      fprintf('(13) vprobemax       [ real ]\n');
      fprintf('(16) vprobemaxdelta  [ real ]\n');
      fprintf('(15) vprobestop      [ false | {true} ]\n');
      fprintf('(22) vreltol         [ real | {1.0e-6} ]\n');
    return;
end

KeyNames = {
'acntrl'
'annotate'
'autonomous'
'checkstrange'
'cmin'
'damping'
'devvars'
'eabstol'
'eigf'
'eigfnorm'
'ereltol'
'fft'
'fftharms'
'fftsamples'
'floquet'
'fmnumber'
'forcetps'
'freltol'
'iabstol'
'ireltol'
'jump'
'jumpabstol'
'jumpreltol'
'load'
'maxdeltav'
'maxiters'
'mem'
'method'
'minper'
'ntoltype'
'maxord'
'parmo'
'powernet'
'printeig'
'printmo'
'printnodes'
'printsh'
'probeharm'
'pseudotransient'
'restart'
'saman'
'samples'
'save'
'savelist'
'skip'
'solver'
'statevars'
'thermalnet'
'timepoints'
'tinc'
'tmax'
'tmin'
'trabstol'
'trreltol'
'uic'
'vabstol'
'vprobe'
'vprobemag'
'vprobemax'
'vprobemaxdelta'
'vprobestop'
'vreltol'
};

options = MPanOptions(KeyNames,varargin{:});

