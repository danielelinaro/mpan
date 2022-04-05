;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Sub-circuit definitions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

subckt FEEDER a b c a7l b7l c7l
parameter FREQ=60
parameter VBUS0=69k
parameter VBUS1=12.47k
parameter PRATING=0.4M
parameter QRATING=-0.4M
parameter BETA=0

Ea a a0 vsource vdc=0
Eb b b0 vsource vdc=0
Ec c c0 vsource vdc=0
Ia a gnd cccs sensedev="Ea" gain1=BETA
Ib b gnd cccs sensedev="Eb" gain1=BETA
Ic c gnd cccs sensedev="Ec" gain1=BETA

TDYg a0 a1l b0 b1l c0 c1l DYGTRANSFORMER v1=VBUS0*sqrt(3) v2=VBUS1 l2=0.06

Bus1 a1l a1r b1l b1r c1l c1r BUS
Bus2 a2l a2r b2l b2r c2l c2r BUS
Bus3 a3l a3r b3l b3r c3l c3r BUS
Bus4 a4l a4r b4l b4r c4l c4r BUS
Bus5 a5l a5r b5l b5r c5l c5r BUS
Bus6 a6l a6r b6l b6r c6l c6r BUS
Bus7 a7l a7r b7l b7r c7l c7r BUS
Bus8 a8l a8r b8l b8r c8l c8r BUS

Ln1 a1r a2l b1r b2l c1r c2l CABLE601 length=0.5 freq=FREQ
Ln2 a2r a3l b2r b3l c2r c3l CABLE601 length=0.5 freq=FREQ
Ln3 a3r a4l b3r b4l c3r c4l CABLE601 length=1.0 freq=FREQ
Ln4 a4r a5l b4r b5l c4r c5l CABLE602 length=1.5 freq=FREQ
Ln5 a5r a6l b5r b6l c5r c6l CABLE602 length=1.5 freq=FREQ
Ln6 a6r a7l b6r b7l c6r c7l CABLE606 length=2.0 freq=FREQ
Ln7 a7r a8l b7r b8l c7r c8l CABLE606 length=2.0 freq=FREQ

Ld1 a2r b2r c2r LOAD pu=5 vload=VBUS1 prating=PRATING
Ld2 a3r b3r c3r LOAD pu=4 vload=VBUS1 prating=PRATING
Ld3 a4r b4r c4r LOAD pu=3 vload=VBUS1 prating=PRATING
Ld4 a5r b5r c5r LOAD pu=3 vload=VBUS1 prating=PRATING
Ld5 a6r b6r c6r LOAD pu=2 vload=VBUS1 prating=PRATING
Ld6 a7r b7r c7r LOAD pu=2 vload=VBUS1 prating=PRATING
Ld7 a8r b8r c8r LOAD pu=1 vload=VBUS1 prating=PRATING

Cap1 a3l b3l c3l CAP pu=1 vload=VBUS1 qrating=QRATING
Cap2 a5l b5l c5l CAP pu=1 vload=VBUS1 qrating=QRATING
Cap3 a7l b7l c7l CAP pu=1 vload=VBUS1 qrating=QRATING

end

subckt BUS al ar bl br cl cr
Ea al ar vsource vdc=0
Eb bl br vsource vdc=0
Ec cl cr vsource vdc=0
end

subckt IDEALYGYGTRANSFORMER a1 a2 b1 b2 c1 c2
parameter v1=1
parameter v2=1
Ta a1 gnd a2 gnd transformer t1=v1 t2=v2
Tb b1 gnd b2 gnd transformer t1=v1 t2=v2
Tc c1 gnd c2 gnd transformer t1=v1 t2=v2
end

subckt YGYGTRANSFORMER a1 a2 b1 b2 c1 c2
parameter v1=1
parameter v2=1
parameter r1=1m
parameter l1=0
parameter rm=500
parameter lm=500
parameter r2=1m
parameter l2=0.0625
Ta a1 a2 gnd gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tb b1 b2 gnd gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tc c1 c2 gnd gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
end

subckt YGYTRANSFORMER a1 a2 b1 b2 c1 c2
parameter v1=1
parameter v2=2
parameter r1=1m
parameter l1=0
parameter rm=500
parameter lm=500
parameter r2=1m
parameter l2=0.0625
Ta a1 a2 gnd n TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tb b1 b2 gnd n TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tc c1 c2 gnd n TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
end

subckt YYGTRANSFORMER a1 a2 b1 b2 c1 c2
parameter v1=1
parameter v2=2
parameter r1=1m
parameter l1=0
parameter rm=500
parameter lm=500
parameter r2=1m
parameter l2=0.0625
Ta a1 a2 n gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tb b1 b2 n gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tc c1 c2 n gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
end

subckt DYGTRANSFORMER a1 a2 b1 b2 c1 c2
parameter v1=1
parameter v2=2
parameter r1=1m
parameter l1=0
parameter rm=500
parameter lm=500
parameter r2=1m
parameter l2=0.0625
Ta a1 a2 b1 gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tb b1 b2 c1 gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tc c1 c2 a1 gnd TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
end

subckt DYTRANSFORMER a1 a2 b1 b2 c1 c2
parameter v1=1
parameter v2=2
parameter r1=1m
parameter l1=0
parameter rm=500
parameter lm=500
parameter r2=1m
parameter l2=0.0625
Ta a1 a2 b1 n TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tb b1 b2 c1 n TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
Tc c1 c2 a1 n TRANSFORMER v1=v1 v2=v2 r1=3*r1 l1=3*l1 rm=3*rm lm=3*lm r2=3*r2 l2=3*l2
end

subckt TRANSFORMER a1 a2 b1 b2
parameter Pn=100e6
parameter fn=60
parameter v1=230k*sqrt(3)
parameter v2=69k*sqrt(3)
parameter r1=1m
parameter l1=0
parameter rm=500
parameter lm=500
parameter r2=1m
parameter l2=0.0625
R1 a1 n1 resistor r=r1*v1*v1/Pn
L1 n1 n2 inductor l=l1*v1*v1/(2*pi*fn*Pn)
Rm n2 b1 resistor r=rm*v1*v1/Pn
;Lm n2 b1 inductor l=lm*v1*v1/(2*pi*fn*Pn)
Trn n2 b1 n3 b2 transformer t1=v1 t2=v2
L2 n3 n4 inductor l=l2*v2*v2/(2*pi*fn*Pn)
R2 n4 a2 resistor r=r2*v2*v2/Pn
end

subckt LOAD a b c
parameter pu=1 ; active power in per unit
parameter vload=12.47k ; load voltage
parameter prating=0.4M
R1 a gnd resistor r=vload*vload/(pu*prating)*3
R2 b gnd resistor r=vload*vload/(pu*prating)*3
R3 c gnd resistor r=vload*vload/(pu*prating)*3
end


subckt CAP a b c
parameter pu=1 ; reactive power in per unit
parameter vload=12.47k ; load voltage
parameter qrating=-0.4M
parameter freq=60
C1 a gnd capacitor c=(-pu*qrating)/(2*pi*freq*vload*vload)/3
C2 b gnd capacitor c=(-pu*qrating)/(2*pi*freq*vload*vload)/3
C3 c gnd capacitor c=(-pu*qrating)/(2*pi*freq*vload*vload)/3
end


subckt RESISTOR al ar bl br cl cr
parameter length=1 ; miles
parameter R11=1
parameter R22=1
parameter R33=1
R1 al ar resistor r=R11*length
R2 bl br resistor r=R22*length
R3 cl cr resistor r=R33*length
end


subckt COUPLEDIND al ar bl br cl cr
parameter length=1 ; miles
parameter freq=60
parameter X11=1
parameter R12=1
parameter X12=1
parameter R13=1
parameter X13=1
parameter X22=1
parameter R23=1
parameter X23=1
parameter X33=1
L1 al am1 inductor l=X11*length/(2*pi*freq)
L2 bl bm1 inductor l=X22*length/(2*pi*freq)
L3 cl cm1 inductor l=X33*length/(2*pi*freq)
CPL1 coupledind ind1="L1" ind2="L2" ind3="L3" k1=X12/sqrt(abs(X11*X22)) k2=X13/sqrt(abs(X11*X33))
CPL2 coupledind ind1="L2" ind2="L3" k1=X23/sqrt(abs(X22*X33))
Va1 am1 am2 ccvs sensedev="L2" gain1=R12*length
Va2 am2 ar  ccvs sensedev="L3" gain1=R13*length
Vb1 bm1 bm2 ccvs sensedev="L1" gain1=R12*length
Vb2 bm2 br  ccvs sensedev="L3" gain1=R23*length
Vc1 cm1 cm2 ccvs sensedev="L1" gain1=R13*length
Vc2 cm2 cr  ccvs sensedev="L2" gain1=R23*length
end


subckt COUPLEDCAP a b c
parameter length=1 ; miles
parameter freq=60
parameter Ba=-1u
parameter Bb=-1u
parameter Bc=-1u
parameter Bd1=1u
parameter Bd2=1u
parameter Bd3=1u
;Cx  a  gnd  capacitor c=(Bd1+Ba+Bc)*length/(4*pi*freq)
;Cy  b  gnd  capacitor c=(Bd2+Ba+Bb)*length/(4*pi*freq)
;Cz  c  gnd  capacitor c=(Bd3+Bb+Bc)*length/(4*pi*freq)
;Cab a    b  capacitor c=-Ba*length/(4*pi*freq)
;Cbc b    c  capacitor c=-Bb*length/(4*pi*freq)
;Cca c    a  capacitor c=-Bc*length/(4*pi*freq)
end


subckt CABLE601 al ar bl br cl cr
; the length of the cable
parameter length=1 ; miles
parameter freq=60

; the resistive part of the cable
R al am bl bm cl cm RESISTOR length=length R11=0.3465 R22=0.3375 R33=0.3414

; the inductive part of the cable
Lc am ar bm br cm cr COUPLEDIND length=length freq=freq \
                                X11=1.0179 X22=1.0478 X33=1.0348 \
                                R12=0.156  R13=0.158  R23=0.1535 \
                                X12=0.5017 X13=0.4236 X23=0.3849

; the capacitive part of the cable
Cc1 al bl cl COUPLEDCAP length=length freq=freq \
                        Ba=-1.9958u Bb=-0.7417u Bc=-1.2595u \
                        Bd1=6.2998u Bd2=5.9597u Bd3=5.6386u
Cc2 ar br cr COUPLEDCAP length=length freq=freq \
                        Ba=-1.9958u Bb=-0.7417u Bc=-1.2595u \
                        Bd1=6.2998u Bd2=5.9597u Bd3=5.6386u

end


subckt CABLE602 al ar bl br cl cr
; the length of the cable
parameter length=1 ; miles
parameter freq=60

; the resistive part of the cable
R al am bl bm cl cm RESISTOR length=length R11=0.7526 R22=0.7475 R33=0.7436

; the inductive part of the cable
Lc am ar bm br cm cr COUPLEDIND length=length freq=freq \
                                X11=1.1814 X22=1.1983 X33=1.2112 \
                                R12=0.158  R13=0.156  R23=0.1535 \
                                X12=0.4236 X13=0.5017 X23=0.3849

; the capacitive part of the cable
Cc1 al bl cl COUPLEDCAP length=length freq=freq \
                        Ba=-1.0817u Bb=-0.6588u Bc=-1.6905u \
                        Bd1=5.699u Bd2=5.1795u Bd3=5.4246u
Cc2 ar br cr COUPLEDCAP length=length freq=freq \
                        Ba=-1.0817u Bb=-0.6588u Bc=-1.6905u \
                        Bd1=5.699u Bd2=5.1795u Bd3=5.4246u

end


subckt CABLE606 al ar bl br cl cr
; the length of the cable
parameter length=1 ; miles
parameter freq=60

; the resistive part of the cable
R al am bl bm cl cm RESISTOR length=length R11=0.7982 R22=0.7891 R33=0.7982

; the inductive part of the cable
Lc am ar bm br cm cr COUPLEDIND length=length freq=freq \
                                X11=0.4463 X22=0.4041  X33=0.4463 \
                                R12=0.3192 R13=0.2849  R23=0.3192 \
                                X12=0.0328 X13=-0.0143 X23=0.0328

; the capacitive part of the cable
Cc1 al bl cl COUPLEDCAP length=length freq=freq \
                        Ba=0 Bb=0 Bc=0 \
                        Bd1=96.8897u Bd2=96.8897u Bd3=96.8897u
Cc2 ar br cr COUPLEDCAP length=length freq=freq \
                        Ba=0 Bb=0 Bc=0 \
                        Bd1=96.8897u Bd2=96.8897u Bd3=96.8897u

end

