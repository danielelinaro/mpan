function [f,C,R]=PvMod(Pars,PN,V,I,StN,X,dX,Time)
%
% Port1: Vs, Is
% Port2: S
% Port3: Id

    Vs = V(1);
    S  = V(2);
%
% Constants
%
    A    = 1.2;
    K    = 1.38062259e-23;
    Zc   = 273.15;
    Q    = 1.60217733e-19;
    Eg   = 1.12;
    T    = 25;
    Tref = 25;
    Ns   = 36*8;
    Ct   = 3.25e-3;
    Iso  = 11.6e-9;
    Ks   = 0;
    So   = 1000;
    Rsh  = 1000;
    Rs   = 5e-3;
    Isco = 5;
%
% Set up
%
    Io = Iso*((T+Zc)/(Tref+Zc))^3*exp(Q*Eg/(A*K)*(1/(Tref+Zc)-1/(T+Zc)));
    C  = zeros(3,3);
    R  = zeros(3,3);

    Vd  = Vs/Ns + Rs*V(3);
    if( Vd > 0.8 )
        Vd = 0.8;
    end
    Exp = exp(Q*Vd/(A*K*(T+Zc)));
%
% Cell
%
    f(1) = -((Isco/So*S + Ct*(T+Ks*S-Tref)) - V(3) - Vd/Rsh) - I(1);
    R(1,1) = -1.0;
    C(1,1) =  1/(Rsh*Ns);
    C(1,2) = -Isco/So + Ct*Ks;
    C(1,3) =  1 - Rs/Rsh;
%
% Irradiance 
%
    f(2)   = I(2);
    R(2,2) = 1;
%
% Id auxiliary port
%
    f(3)   = V(3) - Io*(Exp-1);
    C(3,1) =   - Q/(Ns*A*K*(T+Zc))*Io*Exp;
    C(3,3) = 1 - Q*Rs/(A*K*(T+Zc))*Io*Exp;
end

