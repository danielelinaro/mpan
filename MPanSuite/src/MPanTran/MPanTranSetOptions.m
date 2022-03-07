function options = MPanTranSetOptions(varargin)
%MPanTranSetOptions creates an options structure for PAN TRAN analysis.
%
% Usage: OPTIONS = MPanTranSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...)
%        OPTIONS = MPanTranSetOptions(OLDOPTIONS,'NAME1',VALUE1,...)
%
% OPTIONS = MPanTranSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...) creates
% a PAN TRAN options structure OPTIONS in which the named properties have
% the specified values. Any unspecified properties have default values.
% It is sufficient to type only the leading characters that uniquely
% identify the property. Case is ignored for property names.
%
% OPTIONS = MPanTranSetOptions(OLDOPTIONS,'NAME1',VALUE1,...) alters an
% existing options structure OLDOPTIONS.
%
% MPanTranOptions with no input arguments displays all property names
% and their possible values.
%
%MPanTranSetOptions properties
%(See also the PAN Userguide ... )
%  1 - annotate [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]
%           Degree of annotation. It is an integer number values
%           from 1 to 7. It turns on displaying of generic
%           informations about the analysis run.
%
%  2 - checkstrange [ {false} | true ]
%           Boolean: check if there are some `strange
%           behaviours' of devices. For example, it is checked if
%           bulk-drain and bulk-source parasitic diodes of
%           mosfets are forward biased. This check slows down a
%           bit the simulation and can generate a large number of
%           warnings.
%
%  3 - safetydigits [ integer < 16 | {0} ]
%           how many more digits of the ALU should
%           be preserved by the large conductace transformation.
%
%  4 - maxdevtemp [ real ]
%           Maximum allowed device temperature (Celsius). Available only
%           performing electro-thermal analysis
%
%  5 - maxiter [integer | {10} ]
%           maximum allowed number of Newton
%           iterations at each time step of the time domain
%           analysis. The Newton algorithm is considered as non
%           converging when the iteration number goes above the
%           'maxiter' value. In this case the integration time
%           step is shortened and the Newton algorithm is restarted.
%
%  6 - saman [ {false} | true ]
%           turn on/off the Newton-Samanski method.
%
%  7 - maxinititer [ integer | {100} ]
%           maximum allowed number of Newton
%           iterations during the determination of the initial
%           conditions from which the transient analysis is started.
%
%  8 - maxtminiter [ integer | {100} ]
%           maximum allowed number of Newton
%           iterations when the integration time step length is
%           equal to its minimum allowed value, specified
%           through the 'tmin' parameter.
%
%  9 - printnodes [ {false} | true ]
%           print external/internal node names-index map.
%           This parameter serves mainly for debug purposes.
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
%           some device variabless, such as for example
%           the drain current of mosfets, the anode-cathode
%           current of diodes and currents through capacitors are
%           stored in the simulation output file.
%
% 12 - thermalnet [ {false} | true ]
%           Use the thermal network
%
% 13 - powernet [ {false} | true ]
%           turns on/off the use of power network.
%
% 14 - sparse [ {1} | 2 ]
%           select the sparse solver. This option
%           should be never used by the user and it is intended
%           mainly for debug purposes. The available solvers are:
%
%           1: enhanced <kun> sparse solver by Kundert;
%           2: <klu> sparse solver by Davis.
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
%           available in memory as <memwaveforms>.
%
% 17 - partitioner [ {false} | true ]
%           this option turns on/off the circuitc partitioner.
%           EXPERIMENTAL: not available yet.
%
% 18 - supernode [ {false} | true ]
%           introduce custsets formed by
%           independent voltage sources. These cutsets are known
%           as 'super-nodes'. Super-nodes avoid to add the
%           current through the independent voltage source among
%           the unkowns of the problem and thus reduce the size
%           of the problem increasing efficiency.
%
% 19 - subeqns [ integer | {1000} ]
%           number of equation to feed each thread circuit partitioning.
%           EXPERIMENTAL: not available yet.
%
% 20 - parsolver parsolver
%           turn on/off the parallel analysis by using multiple threads.
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
% 25 - keepmatrixorder [ false | {true} ]
%           when true the algorithm that LU
%           factorise the Jacobian matrix at each iteration of
%           the Newton method tries to keep the same matrix
%           order. In general when the Jacobian matrix is LU
%           factorised the algorithm tries to limit the number of
%           generated fill-ins (extra extried in the sparse
%           Jacobian matrix) and the grouth of the round-off
%           error. This is accomplished by reordering the rows
%           and the column of the Jacobian matrix. Reordering
%           requires the identification of the pivoting entries
%           and submatrix reduction by meas of row/column linear
%           combinations. This is an extremly cpu time consuming
%           task, that often takes a very large portion of the
%           total simulation time, mainly in large circuits.
%           Experience shows that if the Jacobian matrix is LU
%           factorised by keeping a fixed reodering schema the
%           total simulation time reduces of about 6 times. The
%           main drawback is that the grouth of the round-off
%           error is badly controlled and can lead to a failure
%           of the Newton method. Once more experience shows that
%           the Newton algorithm by its intrinsic iterative
%           nature is almost always able to dump the effects of
%           the round-off errors, but still there can be circuit
%           yielding to a very bad conditioned Jacobian matrix
%           that can cause convergence problems.
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
% 32 - checklc [ {false} | true ]
%           find, check and reduce trees of
%           large conductances. This can be an aid to convergence
%           of the integration algorithm, since large conductance
%           reduction prevents growing of round-off errors.
%
% 33 - lclocal [ {false} | true ]
%           use local algorithm for large conductance reduction.
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
% 36 - tinc  [ real | {1.1} ]
%           lengthening factor of the time step at convergence.
%
% 37 - timepoints [ Vector ]
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
% 38 - forcetps [ {false} | true ]
%           force the use of the time points
%           speficied through the <"timepoints"> parameter. Note
%           that since the simulator can not automatically choose
%           the integration time step length when accuracy checks
%           on the found solution such as the local truncation
%           one are not satisfies the inaccuracies reflect in the
%           solution.
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
% 49 - opiabstol [ real | {??} ]
%           Absolute current tolerance for the evaluation of the
%           initial conditions.
%
% 50 - opireltol [ real | {??} ]
%           Relative current tolerance for the evaluation of the
%           initial conditions.
%
% 51 - opvabstol  [ real | {??} ]
%           Absolute voltage tolerance for the evaluation of the
%           initial conditions
%
% 52 - opvreltol  [ real | {??} ]
%           Relative voltage tolerance for the evaluation of the
%           initial conditions
%
% 53 - maxdeltav [ real | {??} ]
%           the maximum allowed variation of node
%           voltage allowed during the iterations of the Newton
%           algorithm. This should aid convergence and avoid
%           possible overflow.
%
% 54 - vmax [ real | {??} ]
%           maximum voltage allowed during iterations
%           of the Newton algorithm
%
% 55 - vmin [ real | {??} ]
%           minimum voltage allowed during iterations
%           of the Newton algorithm.
%
% 56 - damping [ {false} | true ]
%           apply a version of the damped Newton
%           method.
%
% 57 - ggroundstepping [ false | {true} ]
%           turn on/off the gground-stepping
%           continuation algorithm. It acts as "fall-back" method
%           only when the conventional transient analysis fails
%           due to singular MNA matrix.
%
% 58 - gminstepping [ false | {true} ]
%           turn on/off the gmin-stepping
%           continuation algorithm. It acts as "fall-back" method
%           only when the conventional transient analysis could
%           fail.
%
% 59 - pseudotransient [ false | {true} ]
%           turn on/off the pseudo-transient
%           continuation algorithm. It acts as "fall-back" method
%           only when the conventional transient analysis could
%           fail.
%
% 60 - cmin [ false | {true} ]
%           if true parasitic capacitors of
%           suitable values are inserted between each circuit
%           node and ground when the simulator is in trouble to
%           compute the solution. This can aid integration
%           algorithms. However attention must be payed since
%           insertion of these capacitors can yield some circuits
%           to oscillate or even to become unstable!
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
% 62 - ic   [ Vector of string/real ]
%           specifies the initial value of node
%           voltages and branch currents employed in the
%           transient analysis. These values override those
%           automatically computed by the dc analysis as
%           initial guess. A dc analysis is initially done where
%           the ic conditions 'force' the Newton method. It is
%           not ensured that the specified values are met at
%           convergence even though the result should be close to
%           them. The list has the format
%           [node,value,branch,value,...].
%           Example: ["node_name",1E-2,"branch_name",1e-6]
%           For circuit nodes, these initial conditions are "implemented"
%           as Norton equivalents connected to the forced node where
%           the parallel resistor has a conductance equal to the
%           product of the icforce option by the diagonal
%           entry of the MNA matrix corresponding to the forced
%           equation. The magnitude of the independent current
%           sources are such that the product of their currents
%           by the parallel resistors is equal to the given
%           initial conditions.
%
% 63 - icforce [ real | {1.0} ]
%           the initial value of the coefficient
%           employed to force the initial conditions for the
%           Newton algorithm. It has meaning/effect only if the
%           ic option is  specified.
%
% 64 - fft  [ {false} | true ]
%           turns FFT analysis on/off.
%
% 65 - fftfund [ real ]
%           the frequency of the fundamental. A
%           fraction of the reciprocal of this value (time
%           period) is employed to sample waveforms. For more
%           details, see the fftperiod option.
%
% 66 - fftperiod [ real ]
%           The period along which waveforms are sampled and FFT
%           is performed. The sampling interval should begin
%           fftperiod before the tstop value. If the
%           fftestper option is set true, the fftperiod
%           value is automatically adjusted within a maximum
%           value of +40% to fit the current period of the
%           waveforms. Period fitting should improve the accuracy
%           of the computed FFT coefficients. This means that it
%           is not mandatory to give an exact value of the
%           fftperiod it can be automatically adjusted within
%           the above specified interval.
%
% 67 - fftestper [ {false} | true ]
%           estimation of the period of
%           waveforms along which the FFT transformation is
%           applied. If this parameter is true it is not
%           mandatory to specify an accurate value of fftperiod
%           since it is automatically adjusted within a maximum
%           relative value of +40% to fit the current period of
%           waveforms. The algorithm that tries to find the
%           period computes the tangent to the trajectory in the
%           state plane, that is denoted by Tg in the
%           following, at a given time instant. More precisely
%           along a suitable time interval it finds the largest
%           value of the L1 norm of Tg and records the time
%           instant, say ts, at which it has been found. At
%           ts also the current value of state variables is
%           saved; define this vector as Xs. Then it is
%           computed the scalar product of Tg and the Ds
%           vector obtained as the difference between the current
%           value of state variables and Xs. When the scalar
%           product is equal to zero or better is less than a
%           choosen threshold thus one period of the waveforms
%           has been past from the Ts time instant.
%
% 68  fftharms [ integer | {4} ]
%           the number of harmonics computed by FFT.
%
% 69  fftsamples [ integer | {??} ]    The number of sampling points in the FFT analysis.
%           This parameters is effective only if it specifies a
%           number of samples greater than 4 * fftharms + 1,
%           which represents the minimum allowed number of
%           employed samples.
%
% 70 - fi   [ {false} | true ]
%           turn on and off the computation of
%           the Fourier integrals, i.e. the computation of the
%           components of the waveform spectra.
%
% 71 - fifund [ real ]
%           the frequency of the fundamental. A
%           fraction of the reciprocal of this value (time
%           period) is employed to sample waveforms. For more
%           details, see the fiperiod option.
%
% 72 - fiperiod [ real ]
%           The period along which Fourier integrals of the
%           computed wavefors are performed. The interval should
%           begin fiperiod before the tstop value. If the
%           fiestper option is set true, the fiperiod
%           value is automatically adjusted within a maximum
%           value of +40% to fit the current period of the
%           waveforms. Period fitting should improve the accuracy
%           of the Forurier integrals. This means that it is not
%           mandatory to give an exact value of the fiperiod
%           since it can be automatically adjusted within the
%           above specified interval.
%
% 73 - fiestper [ {false} | true ]
%           estimate the period of waveforms to
%           which Fourrier integrals are applied. If this
%           parameter is true it is not mandatory to specify an
%           accurate value of ifperiod since it is
%           automatically adjusted within a maximum relative
%           value of +40% to fit the current period of waveforms.
%           The algorithm that tries to find the period computes
%           the tangent to the Tg trajectory in the phase space
%           at a given time instant. More precisely along a
%           suitable time interval it finds the largest value of
%           the L1 norm of Tg and records the time instant, say
%           ts, at which it has been found. At ts also the
%           current value of state variables is saved; define
%           this vector as Xs. It is thus computed the scalar
%           product of Tg and the Ds vector obtained as the
%           difference between the current value of state
%           variables and Xs. When the scalar product is equal
%           to zero or better is less than a choosen threshold,
%           it is assumed that one period of the waveforms has
%           been past from the Ts time instant.
%
% 74 - fifreq [ vector ]
%           list of frequecies at which the Fourier integrals are computed.
%
% 75 - findperiod [ {false} | true ]
%           find period values during the tran
%           analysis. This can be used to monitor synchronization
%           transients. Unconsistent results are possibly found
%           if a nonperiodic dynamics is present. Period doubling
%           may also cause problems.
%
% 76 - monodromy [ {false} | true ]
%           compute the monodromy matrix of the circuit.
%
% 77 - parmo [ {false} | true ]
%           turn on/off the use of multiple
%           threads in computing the monodromy matrix.
%
% 78 - printmo [ {false} | true ]
%           print the monodromy matrix of the circuit.
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
% 80 - lyapunov [ {false} | true ]
%           compute the Lyapunov exponents and
%           the Kaplan-York dimension of the tran circuit
%           trajectory. It is possible to chose different
%           policies concerning the time instant at which
%           monodromy is reset and QR computed: Time based (after
%           a given time) or Sample based (after a fixed number
%           of time points). Sample based is the default
%           behaviour if parameter lyapstep is not specified.
%
% 81 - lyapstep [ real ]
%           force time step for the computation of
%           Lyapunov exponents (and resetting monodromy to identity).
%
% 82 - lyapsamp [ {false} | true ]
%           turn on/off printing of Lyapunov
%           exponents and Kaplan-Yorke dimension run time during
%           the simulation.
%
% 83 - lyapprint [ {false} | true ]
%           Number of time samples that force
%           computation of QR and resetting monodromy matrix.
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
%NOTES:
%
% See also
%    MPanGet, MPanGet,
%    MPanGet, MPanGet,,
%    CVDenseJacFn, CVBandJacFn, CVJacTimesVecFn
%    CVPrecSetupFn, CVPrecSolveFn
%    CVGlocalFn, CVGcommFn
%    CVMonitorFn
%    CVRhsFnB,
%    CVDenseJacFnB, CVBandJacFnB, CVJacTimesVecFnB
%    CVPrecSetupFnB, CVPrecSolveFnB
%    CVGlocalFnB, CVGcommFnB
%    CVMonitorFnB

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
    fprintf('(32) checklc         [ {false} | true ]\n');
    fprintf('(2)  checkstrange    [ {false} | true ]\n');
    fprintf('(60) cmin            [ false | {true} ]\n');
    fprintf('(56) damping         [ {false} | true ]\n');
    fprintf('(15) decimation      [ real ]\n');
    fprintf('(11) devcurr         [ {false} | true ]\n');
    fprintf('(64) fft             [ {false} | true ]\n');
    fprintf('(67) fftestper       [ {false} | true ]\n');
    fprintf('(65) fftfund         [ real ]\n');
    fprintf('(68) fftharms        [ integer | {4} ]\n');
    fprintf('(66) fftperiod       [ real ]\n');
    fprintf('(69) fftsamples      [ integer | {??} ]  69\n');
    fprintf('(70) fi              [ {false} | true ]\n');
    fprintf('(73) fiestper        [ {false} | true ]\n');
    fprintf('(74) fifreq          [ vector ]\n');
    fprintf('(71) fifund          [ real ]\n');
    fprintf('(75) findperiod      [ real ]\n');
    fprintf('(72) fiperiod        [ real ]\n');
    fprintf('(38) forcetps        [ {false} | true ]\n');
    fprintf('(57) ggroundstepping [ false | {true} ]\n');
    fprintf('(58) gminstepping    [ false | {true} ]\n');
    fprintf('(47) iabstol         [ real | {1.0e-12} ]\n');
    fprintf('(62) ic              [ Vector of string/real ]\n');
    fprintf('(63) icforce         [ real | {1.0} ]\n');
    fprintf('(48) ireltol         [ real | {1.0e-6}\n');
    fprintf('(79) jump            [ {false} | true ]\n');
    fprintf('(25) keepmatrixorder [ false | {true} ]\n');
    fprintf('(33) lclocal         [ {false} | true ]\n');
    fprintf('(30) load            [ String ]\n');
    fprintf('(83) lyapprint       [ {false} | true ]\n');
    fprintf('(82) lyapsamp        [ {false} | true ]\n');
    fprintf('(81) lyapstep        [ real ]\n');
    fprintf('(80) lyapunov        [ {false} | true ]\n');
    fprintf('(53) maxdeltav       [ real | {??} ]\n');
    fprintf('(4)  maxdevtemp      [ real ]\n');
    fprintf('(7)  maxinititer     [ integer | {100} ]\n');
    fprintf('(5)  maxiter         [ integer | {10} ]\n');
    fprintf('(8)  maxtminiter     [ integer | {100} ]\n');
    fprintf('(31) mem             [ list ]\n');
    fprintf('(21) method          [ {1} | 2 ]\n');
    fprintf('(76) monodromy       [ {false} | true ]\n');
    fprintf('(85) noisefmax       [ real ]\n');
    fprintf('(84) noiseinj        [ {1} | 2 ]\n');
    fprintf('(24) ntoltype        [ 1 | {2} | 3]\n');
    fprintf('(49) opiabstol       [ real | {??} ]\n');
    fprintf('(50) opireltol       [ real | {??} ]\n');
    fprintf('(51) opvabstol       [ real | {??} ]\n');
    fprintf('(52) opvreltol       [ real | {??} ]\n');
    fprintf('(22) maxord          [ 1 | {2} | 3 | 4 | 5 | 6 ]\n');
    fprintf('(77) parmo           [ {false} | true ]\n');
    fprintf('(20) parsolver       [ {false} | true ]\n');
    fprintf('(17) partitioner     [ {false} | true ]\n');
    fprintf('(13) powernet        [ {false} | true ]\n');
    fprintf('(78) printmo         [ {false} | true ]\n');
    fprintf('(9)  printnodes      [ {false} | true ]\n');
    fprintf('(59) pseudotransient [ false | {true} ]\n');
    fprintf('(16) rawmode         [ 0 | {1} | 2 | 3 | 4 | 5 | 6 | 7 ]\n');
    fprintf('(28) restart         [ false | {true} ]\n');
    fprintf('(3)  safetydigits    [ integer < 16 | {0} ]\n');
    fprintf('(6)  saman           [ {false} | true ]\n');
    fprintf('(29) save            [ String ]\n');
    fprintf('(10) savelist        [ list ]\n');
    fprintf('(39) savetime        [ real ]\n');
    fprintf('(86) seed            [ integer ]\n');
    fprintf('(61) skip            [ 0 | {1} | 2 ]\n');
    fprintf('(26) skipdc          [ {false} | true ]\n');
    fprintf('(14) sparse          [ {1} | 2 ]\n');
    fprintf('(19) subeqns         [ integer | {1000} ]\n');
    fprintf('(18) supernode       [ {false} | true ]\n');
    fprintf('(12) thermalnet      [ {false} | true ]\n');
    fprintf('(37) timepoints      [ vector ]\n');
    fprintf('(36) tinc            [ real | {1.1} ]\n');
    fprintf('(35) tmax            [ real ]\n');
    fprintf('(34) tmin            [ real ]\n');
    fprintf('(43) trabstol        [ real | {1.0e-12} ]\n');
    fprintf('(44) trreltol        [ real | {1.0e-3} ]\n');
    fprintf('(40) tstart          [ real | {1.0e-6} ]\n');
    fprintf('(42) tstop           [ real | {1.0e-6} ]\n');
    fprintf('(27) uic             [ {0} | 1 | 2 ]\n');
    fprintf('(45) vabstol         [ real | {1.0e-6} ]\n');
    fprintf('(54) vmax            [ real | {??} ]\n');
    fprintf('(55) vmin            [ real | {??} ]\n');
    fprintf('(46) vreltol         [ real | {1.0e-6} ]\n');
    return;
end

KeyNames = {
    'acntrl'
    'annotate'
    'checklc'
    'checkstrange'
    'cmin'
    'damping'
    'decimation'
    'devvars'
    'fft'
    'fftestper'
    'fftfund'
    'fftharms'
    'fftperiod'
    'fftsamples'
    'fi'
    'fiestper'
    'fifreq'
    'fifund'
    'findperiod'
    'fiperiod'
    'forcetps'
    'ggroundstepping'
    'gminstepping'
    'iabstol'
    'ic'
    'icforce'
    'ireltol'
    'jump'
    'keepmatrixorder'
    'lclocal'
    'load'
    'lyapprint'
    'lyapsamp'
    'lyapstep'
    'lyapunov'
    'maxdeltav'
    'maxdevtemp'
    'maxinititer'
    'maxiter'
    'maxtminiter'
    'mem'
    'method'
    'monodromy'
    'noisefmax'
    'noiseinj'
    'ntoltype'
    'opiabstol'
    'opireltol'
    'opvabstol'
    'opvreltol'
    'maxord'
    'parmo'
    'parsolver'
    'partitioner'
    'powernet'
    'printmo'
    'printnodes'
    'pseudotransient'
    'rawmode'
    'restart'
    'safetydigits'
    'saman'
    'save'
    'savelist'
    'savetime'
    'seed'
    'skip'
    'skipdc'
    'sparse'
    'subeqns'
    'supernode'
    'thermalnet'
    'timepoints'
    'tinc'
    'tmax'
    'tmin'
    'trabstol'
    'trreltol'
    'tstart'
    'tstop'
    'uic'
    'vabstol'
    'vmax'
    'vmin'
    'vreltol'};

options = MPanOptions(KeyNames,varargin{:});

