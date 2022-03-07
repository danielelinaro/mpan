function varargout = MPanShooting(NAME, PERIOD, OPTIONS)
% MPanShooting runs a PAN shooting analysis. A netlist must be already loaded
% with MPanNetLoad.
%
% Usage: MPanTran(NAME, PERIOD)
%        MPanTran(NAME, PERIOD, OPTIONS)
%        S = MPanTran(NAME, PERIOD, OPTIONS)
%
% MPanShooting(NAME, PERIOD) runs a PAN shooting analysis whose identifier is
% NAME. The PERIOD parameter is mandatory and is the extimated value of the
% steady state periodic solution that is searched.The default options are
% used.
%
% MPanShooting(NAME, PERIOD, OPTIONS) runs a PAN shooting analysis whose
% identifier is NAME. The PERIOD parameter is mandatory and is the extimated value of the
% steady state periodic solution that is searched. The OPTIONS structure is used.
%
% S = MPanShooting(NAME, PERIOD, OPTIONS) works as the previous one
% but S is an output cell arrays and each cell contains
% a label and a waveform. The waveform are those specified with the mem
% field in OPTIONS. If mem is not specified S is empty.
%
% Steady state computation through shooting method.
% 
% Shooting is a time domain analysis that efficiently determines the steady state
% behaviour of both autonomous and nonautonomous circuits. When dealing with
% autonomous circuits, the working period is automatically computed by starting
% from an initial guess given by the user at the beginning of the analysis. When
% a limit cycle of a circuit is found, it is possible to compute the Floquet
% multipliers that give insight to the local stability of the limit cycle. When
% the annotation level is suitably set at each iteration of the algorithm some
% usefull information is printed.
% For example consider the following line:
% 
% || R* || =  12.992    D[10] R[10] F* = 5.00000000 MHz <4>
% Max |dX| =  37.117 m of <trp>  > 1e-4 * (max(|X(t)|) = 53.797) + 1e-6
% Max |dR| =   2.277 u of <x1.y> > 1e-4 * (max(|X(t)|) =  9.415 m) + 1e-06
% 
% where || R  || means the residue, that is, the norm of the right hand side
% vector of the steady state problem that is solved by employing the Newton
% iterative method. A possible '*' character means that the sensitivity matrix
% was computed, 'D[10]' tells that 10 entries of the updating vector computed by
% the Newton algorithm do not satisfy the convergence criterion, R[10] tells
% that 10 equations do not meet the convergence criterion, F* = 5.00000000 MHz
% shows the currently computed working frequency of the circuit, obviously it has
% meaning only if the circuit is autonomous (oscillator). A possible '*'
% character tells that the algorithm was unable to suitably determine the working
% period and an old estimation was thus used, eventually the <4> integer shows
% that the transient analysis was continued up to 4 times the previously
% estimated period in order to estimate a new and better one. When the shooting
% method damps the updating the 'S =  1.00e-01' notice appears showing the
% damping factor, equal to 0.1 in this example.
% 'Max |dX| =  37.117 m of <trp> over max(|X(t)|) =  53.797'
% is the maximum solution difference related to the <trp> variable in this
% exmaple, obtained by subtracting solutions at the beginning and at the end of
% the circuit working period. 'max(|X(t)|)' is tha maximum abslolute value
% assumed the the time domain waveform describing the <trp> solution along one
% working period.
% 'Max |dR| <X1.y> =  2.2779 u > 0.0001 * (max(|X(t)|) =  9.4156 m) + 1e-06
% is the maximum error of the residue of the Newton method. Once more a
% indications about the related variable and about tha maximum value assumed in a
% working period are given.
%
% The algorithm computes also the eigenfunctions related to the variational
% model of the circuit at steady state. The variational model is characterised
% by the fundamental matric M that admits the `v(T)' left eigenvectors and
% the `u(T)' right eigenvectors. The `v(t)' and `u(t)' eigenfunctions along
% one working period `T' of the circuit are determined starting from the value
% of eigenvectors at the beginning of the period. With respect to the state
% formulation these eigenfunctions are determined for each equation of the MNA
% formulation (referring to nodes and currents of current controlled elements).
% If the circuit is autonomous the eigenvector and thus the derived
% eigenfunction associated to the Floquet multiplier equal to 1 are
% automatically identified. In general there can be more than one Floquet
% multiplier very close to 1 (think of high Q oscillators); that found as the
% representative of the Floquet multiplier theoretically equal to 1 is
% marked by the `*' symbol in the multiplier printout. The number of the
% Floquet multipliers differs from the number of state variables. This happens
% since the modified nodal analysis formulation is adopted in the simulator.
% Floquet multipliers refer to node voltages of voltage controlled elemets and
% branch currents of current controlled elements (capacitors and inductors for
% example). If a capacitor is connected between nodes 'k' and 'j' two Floquet
% multipliers are computed one for node voltage 'k' and the other for node
% voltage 'j'. The 'vB(t)' eigenfunctions refer to the product of the `v(t)'
% ones with the `B(t)' function. The `B(t)' function represent the sensitivity
% of pseudo-state variables (for example node voltages) with respect to
% current injected into the node (the same comment can be aplied to branch
% currents).
% For more theoretical details see
% 
% M. Farkas, `Periodic Motions, Springer-Verlag`, 1994.
% 
% A. Demir, A. Mehrotra and J. Roychowdhury,
% `Phase Noise in Oscillators: A Unified Theory and Numerical Methods for
% Characterization`, IEEE Trans. on CAS-I, Vol. 47, No. 5, May 2000,
% pp. 655-674.
% 
% A. Brambilla, P. Maffezzoni, G. Storti-Gajani,
% `Computation of Period Sensitivity Functions for the Simulation of
% Phase Noise in Oscillators', IEEE Trans. on CAS-I, Vol. 52, No. 4,
% April 2005.
% 
% Waveforms that can be stored in memory and made available to the control
% analysis are:
% 
% 1) Node voltage and branch current waveforms can be retrieved through
% the statement 'get("ShootName.node")', time is stored in the 'time'
% vector that can be retrieved through 'get("ShootName.time")'
% 
% 2) Node voltage and branch current spectra can be retrieved through the
% statement 'get("ShootName.node:spectrum")'. The frequency samples are
% stored in the 'freq' vector. It can be retrived through the statement
% 'get("ShootName.freq").
% 
% 3) device current waveforms, the related time samples can be retrieved in 
% the 'devtime' vector.
% 
% 4) Floquet periodic eigenfunctions that can be retrived through the
% statement 'get("ShootName.u1@n1"), where 'u1' is the type of eigenfunction
% and 'n1' is the referring circuit node, the related time samples are
% stored in the 'eigtime' vector.
% 
% 5) Floquet multipliers that can be retrived through the statement
% 'get("ShootingName.floquet")'.
% 
% 6) Sensitivity matrices from a time point of the shooting analysis to the
% next one. The left product of these matrices constitutes the monodromy
% matrix. These matrices can be retrived through the statement
% 'get("ShootingName.sensmtrx")'.
%
%
% See also
%    MPanShootingSetOptions
%
% Angelo Brambilla - Federico Bizzarri 
% Copyright (c) 2015.
% Revision: 1.0.0 $Date: 2015/04/10$

global MPanSuite_NETLIST_INFO
if isempty(MPanSuite_NETLIST_INFO) || isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME)
    error('MPanSuiteError: a MPanSuiteNetlist is not loaded yet.')
end

if nargin < 2
    error('MPanSuiteError: at least 2 input arguments are required.')
end

if nargout > 1
     error('MPanSuiteError: no more than 1 output can be assigned')
end

if (nargin >= 2) && ~isempty(PERIOD)
    str_command = [NAME ' shooting period = ' num2str(PERIOD,'%23.16e')];
else
    error('MPanSuiteError: at now period must be specified for a shooting analysis.')
    % 49 - period [ real ]
    %      If the circuit is autonomous it is an
    %      estimation of the working period; if the circuit is
    %      non-autonomous it represents the fixed working period
    %      of the circuit and it is not computed by the shooting
    %      analysis. If the initial guess is loaded from a file
    %      storing results results by a previous shooting
    %      analysis and this parameter is omitted, the period is
    %      set equal to that of the previous loaded analysis. If
    %      the initial guess is taken from a previous shooting
    %      analysis, successfully terminated before the current
    %      one and this parameter is omitted, the period is set
    %      equal to that of the previous analysis.
    %
end

if nargin == 3
    KeyNames = fieldnames(OPTIONS);
    m = numel(KeyNames);
    for k = 1:m
        key = KeyNames{k};
        if ~isempty(OPTIONS.(key))
            if strcmp(key,'savelist') || strcmp(key,'mem') || strcmp(key,'statevars')
                str_command = [str_command ' ' key ' = [']; %#ok<*AGROW>
                nrow = numel(OPTIONS.(key));
                for j = 1:nrow-1
                    str_command = [str_command '"' OPTIONS.(key){j} '",'];
                end
                str_command = [str_command '"' OPTIONS.(key){nrow} '"] '];
            elseif strcmp(key,'vprobe')
                nrow = numel(OPTIONS.(key));
                if nrow > 2
                    error('MPanSuiteError: vprobe options must be a list with 1 or 2 elements.')
                else
                    str_command = [str_command ' ' key ' = [']; %#ok<*AGROW>
                    for j = 1:nrow-1
                        str_command = [str_command '"' OPTIONS.(key){j} '",'];
                    end
                    str_command = [str_command '"' OPTIONS.(key){nrow} '"] '];
                end
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

