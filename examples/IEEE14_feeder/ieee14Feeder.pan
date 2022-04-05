ground electrical gnd

#ifdef PAN
parameter F0=50
parameter VBASE=230k
parameter PBASE=100M
parameter TSTOP=500

#ifdef DYNAMIC_LINES
parameter DYNAMIC=yes
#else
parameter DYNAMIC=no
#endif // DYNAMIC_LINES
parameter LDTYPE=(DYNAMIC) ? 0 : 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parameters D=2 VDIG=1 CLK_PERIOD=(1/4)/F0 OMEGA=2*pi*F0 VDC_REF=660 RD=100M \
           MULT_DIS=800

parameters MULT_PV=4*2 N_SERIES_PV=8
parameters LOW_IRR=200 HIGH_IRR=1k

parameters TSTOP=20*50m

parameters ENV_START=TSTOP+16*CLK_PERIOD ENV_STOP=ENV_START+29k*CLK_PERIOD \
           T_IRR_STOP_SWEEP=ENV_START+10k*CLK_PERIOD

#endif

include feeder.inc

options outintnodes=yes rawkeep=yes topcheck=2

#ifdef PAN

TrI   tran    stop=TSTOP+0.2*CLK_PERIOD uic=2 restart=1 ireltol=1m \
              iabstol=1u nettype=no annotate=5 acntrl=3

ShI   shooting fund=F0 restart=0 solver=1 floquet=yes \
               method=2 maxord=2 damping=0.4 tmax=1m/F0 eabstol=1m \
               iabstol=1n nettype=no ereltol=5m fft=yes fftharms=512

Dc dc nettype=2 print=yes sparse=2 gminstepping=false ggroundstepping=no

ShPf shooting fund=F0 solver=0 floquet=true \
              method=2 maxord=2 nettype=3 restart=no \
              tmax=1m/F0 ereltol=1m eabstol=1m devvars=yes \
              printmo=0 trabstol=10n iabstol=1n

TrZ tran stop=ENV_START savetime=TSTOP+4*CLK_PERIOD restart=0 \
         ireltol=1m iabstol=1u nettype=1 method=2 maxord=2

Env envelope fund=F0 stop=ENV_STOP method=2 maxord=2 nettype=1 restart=no \
             ireltol=1m iabstol=1u mktpu=yes acntrl=3 devvars=1 ltefactor=1

Save control begin

   save( "mat5", "envel.mat", "time",    get("Env.time"),       \
                              "omega01", get("Env.omega01" ),   \
                              "omega02", get("Env.omega02" ),   \
                              "pm01",    get("Env.pm01" ),      \
                              "pm02",    get("Env.pm02" ),      \
                              "pos",     get("Env.Solar.pos" ), \
                              "S",       get("Env.Solar.S" ) );
endcontrol

#endif

begin power

; Lines

Li02_05   bus02   bus05  powerline prating=100M    vrating=69k   r=0.05695 \
                                         x=0.17388       b=0.034
Li06_12   bus06   bus12  powerline prating=100M    vrating=13.8k r=0.12291 \
                                         x=0.25581       b=0
Li12_13   bus12   bus13  powerline prating=100M    vrating=13.8k r=0.22092 \
                                         x=0.19988       b=0
Li06_13   bus06   bus13  powerline prating=100M    vrating=13.8k r=0.06615 \
                                         x=0.13027       b=0
Li06_11   bus06   bus11  powerline prating=100M    vrating=13.8k r=0.09498 \
                                         x=0.1989        b=0
Li11_10   bus11   bus10  powerline prating=100M    vrating=13.8k r=0.08205 \
                                         x=0.19207       b=0
Li09_10   bus09   bus10  powerline prating=100M    vrating=13.8k r=0.03181 \
                                         x=0.0845        b=0
Li09_14   bus09   bus14  powerline prating=100M    vrating=13.8k r=0.12711 \
                                         x=0.27038       b=0
Li14_13   bus14   bus13  powerline prating=100M    vrating=13.8k r=0.17093 \
                                         x=0.34802       b=0
Li07_09   bus07   bus09  powerline prating=100M    vrating=13.8k r=0       \
                                         x=0.11001       b=0
Li01_02   bus01   bus02  powerline prating=100M    vrating=69.0k r=0.01938 \
                                         x=0.05917       b=0.0528
Li03_02   bus03   bus02  powerline prating=100M    vrating=69.0k r=0.04699 \
                                         x=0.19797       b=0.0438
Li03_04   bus03   bus04  powerline prating=100M    vrating=69.0k r=0.06701 \
                                         x=0.17103       b=0.0346
Li01_05   bus01   bus05  powerline prating=100M    vrating=69.0k r=0.05403 \
                                         x=0.22304       b=0.0492
Li05_04   bus05   bus04  powerline prating=100M    vrating=69.0k r=0.01335 \
                                         x=0.04211       b=0.0128
Li02_04   bus02  bus04  powerline prating=100M    vrating=69.0k r=0.05811 \
                                         x=0.17632       b=0.0374

Tg1      pm01  omega01  powertg type=1 omegaref=1 r=0.02 pmax=10 pmin=0 \
                               ts=0.1 tc=0.45 t3=0 t4=12 t5=50 gen="G1" \
			       dza=36m/F0

E1  bus01  avr01 poweravr vrating=69k type=2 vmax=20 vmin=-20 ka=200 ta=0.02 \
                          kf=0.002 tf=1 ke=1 te=0.2  tr=0.001 ae=0.0006 be=0.9

G1  bus01  avr01  pm01  omega01  powergenerator slack=yes \
           prating=610M \
	    vrating=69k        vg=1.06    qmax=9.9 \
               qmin=-9.9     vmax=1.2     vmin=0.8    omegab=OMEGA     \
	       type=52   \
		 xl=0.2396     ra=0         xd=0.8979    xdp=0.2998  xds=0.23 \
	       td0p=7.4      td0s=0.03      xq=0.646     xqp=0.646   xqs=0.4  \
	       tq0p=0        tq0s=0.033     m=10.296      d=D 

; Second synchronous machine - voltage regualator - turbine governor
Tg2      pm02  omega02 agc02 powertg type=1 omegaref=1 r=0.02 pmax=4 pmin=0.3 \
                               ts=0.1 tc=0.45 t3=0 t4=12 t5=50 gen="G2"

E2  bus02  avr02 poweravr vrating=69k type=2 vmax=4.38 vmin=0 ka=20 ta=0.02 \
                          kf=0.001 tf=1 ke=1 te=1.98 tr=0.001 ae=0.0006 be=0.9

G2  bus02  avr02   pm02  omega02  powergenerator \
           prating=60M \
	    vrating=69k      vg=1.045     qmax=0.5 \
	       qmin=-0.4     vmax=1.2    vmin=0.8     omegab=OMEGA     \
	       type=6  pg=40/60 \
		 xl=0          ra=0.0031   xd=1.05       xdp=0.185   xds=0.13  \
	       td0p=6.1      td0s=0.04     xq=0.98       xqp=0.36   xqs=0.13 \
	       tq0p=0.3      tq0s=0.099     m=13.08        d=D

E3  bus03  avr03 poweravr vrating=69k type=2 vmax=4.38 vmin=0 ka=20 ta=0.02 \
                          kf=0.001 tf=1 ke=1 te=1.98 tr=0.001 ae=0.0006 be=0.9
G3  bus03  avr03 powergenerator \
           prating=60M \
	    vrating=69k      vg=1.01      qmax=0.4  \
	       qmin=0        vmax=1.2    vmin=0.8     omegab=OMEGA     \
	       type=6  pg=0   \
		 xl=0          ra=0.0031   xd=1.05       xdp=0.185   xds=0.13 \
               td0p=6.1      td0s=0.04     xq=0.98       xqp=0.36    xqs=0.13 \
	       tq0p=0.3     tq0s=0.099      m=13.08        d=D

E6  bus06  avr06 poweravr vrating=13.8k type=2 vmax=6.81 vmin=1.395 ka=20 \
                 ta=0.02 kf=0.001 tf=1 ke=1 te=0.7  tr=0.001 ae=0.0006 be=0.9
G6  bus06  avr06 powergenerator \
            prating=25M \
	    vrating=13.8k    vg=1.07      qmax=0.24 \
	       qmin=-0.06    vmax=1.2    vmin=0.8     omegab=OMEGA     \
	       type=6  pg=0 \
		 xl=0.134      ra=0.0014   xd=1.25       xdp=0.232   xds=0.12  \
	       td0p=4.75     td0s=0.06     xq=1.22       xqp=0.715   xqs=0.12  \
	       tq0p=1.5      tq0s=0.21      m=10.12         d=D

E8  bus08  avr08 poweravr vrating=18k type=2 vmax=10 vmin=-1 ka=20 \
                 ta=0.02 kf=0.001 tf=1 ke=1 te=0.7  tr=0.001 ae=0.0006 be=0.9
G8  bus08  avr08 powergenerator \
           prating=25M \
	    vrating=18k      vg=1.09      qmax=0.24 \
	       qmin=-0.06    vmax=1.2    vmin=0.8     omegab=OMEGA     \
	       type=6  pg=0 \
	         xl=0.134      ra=0.0014   xd=1.25       xdp=0.232   xds=0.12  \
	       td0p=4.75     td0s=0.06     xq=1.22       xqp=0.715   xqs=0.12  \
	       tq0p=1.5      tq0s=0.21      m=10.12        d=D

; Center of inertia

Coi  omegacoi powercoi gen="G1" gen="G2" gen="G3" gen="G6" gen="G8" type=3

; Transformers

Tr05_06   bus06   bus05  powertransformer \
                          prating=100M  vrating=13.8k   kt=5 \
                                r=0           x=0.25202  a=0.932

Tr04_09   bus09   bus04  powertransformer \
                          prating=100M  vrating=13.8k   kt=5 \
			        r=0           x=0.55618  a=0.969

Tr04_07   bus07   bus04  powertransformer \
                          prating=100M  vrating=13.8k   kt=5 \
			        r=0           x=0.20912  a=0.978

Tr08_07   bus07   bus08  powertransformer \
                          prating=100M  vrating=13.8k   kt=1.304348 \
			        r=0           x=0.17615  a=1

; Loads

Lo11     bus11  powerload prating=100M vrating=13.8k pc=0.035  qc=0.018 \
                          vmax=1.2  vmin=0.8
Lo13     bus13  powerload prating=100M vrating=13.8k pc=0.135  qc=0.058 \
                          vmax=1.2  vmin=0.8
Lo03     bus03  powerload prating=100M vrating=69k   pc=0.942 qc=0.19  \
                          vmax=1.2  vmin=0.8
Lo05     bus05  powerload prating=100M vrating=69k   pc=0.076 qc=0.016 \
                          vmax=1.2  vmin=0.8
Lo02     bus02  powerload prating=100M vrating=69k   pc=0.217 qc=0.127 \
                          vmax=1.2  vmin=0.8
Lo06     bus06  powerload prating=100M vrating=13.8k pc=0.112 qc=0.075  \
                          vmax=1.2  vmin=0.8
Lo04     bus04  powerload prating=100M vrating=69k   pc=0.478 qc=0.04  \
                          vmax=1.2  vmin=0.8
Lo14     bus14  powerload prating=100M vrating=13.8k pc=0.149 qc=0.05   \
                          vmax=1.2  vmin=0.8
Lo12     bus12  powerload prating=100M vrating=13.8k pc=0.061 qc=0.016 \
                          vmax=1.2  vmin=0.8
Lo10     bus10  powerload prating=100M vrating=13.8k pc=0.09  qc=0.058 \
                          vmax=1.2  vmin=0.8
Lo09     bus09  powerload prating=100M vrating=13.8k pc=0.295  qc=0.166 \
                          vmax=1.2  vmin=0.8

Pec      bus04  a1 b1 c1 powerec type=3 f0=F0 v0=1 vrating=69k

end

Fdr    a1  b1  c1  a7  b7  c7 FEEDER

T3     a7  b7  c7  a13 b13 c13 gnd TRANF3PHDY  N=13.8k/380*1.5

Ima    a13    gnd   a13   xa13  cccs gain1=MULT_DIS
Imb    b13    gnd   b13   xb13  cccs gain1=MULT_DIS
Imc    c13    gnd   c13   xc13  cccs gain1=MULT_DIS

Ix    xa13   xb13  xc13   pref   qref   svcpwr   LCL#SVC

Qref  qref   gnd   vsource vdc=0

Solar pvout  SOLAR
Cy    pvout  gnd   capacitor c=1m ic=VDC_REF
Iz    pvout  gnd   svcpwr  gnd   nport func1=i(p1)*limit(v(p1),500,700)-v(p2) func2=i(p2)

Pid1    pref  gnd   pvout  vref PID KP=20 KI=50

Pvref   vref  gnd   vsource vdc=VDC_REF

subckt TRANF3PHDY pa pb pc sa sb sc ss
// Three phase transformer D-Y connection
// pa, pb, pc -- primary   'a', 'b' and 'c' phases
// sa, sb, sc -- secondary 'a', 'b' and 'c' phases
// ss -- secondary center star nodes. 

parameters N=1

Ta  pa  pb  sa  ss  TRANF1PH  N=N
Tb  pb  pc  sb  ss  TRANF1PH  N=N
Tc  pc  pa  sc  ss  TRANF1PH  N=N
ends

subckt TRANF1PH pp pn sp sn
parameters RP1=10m LP1=1m RMAG=1G LM=200 N=1 LS1=0.1m

R1p    pp   n10   resistor r=RP1
L1p   n10   n20   inductor l=LP1
Rdp   n10   n20   resistor r=RD
Rmg   n20    pn   resistor r=RMAG
;Lmg   n20    pn   inductor l=LM
T1    n20    pn   n30   sn  transformer t1=N t2=1
L1s   n30    sp   inductor l=LS1
Rds   n30    sp   resistor r=RD

ends

subckt LCL#SVC  a  b  c  pref  qref  pwr
parameters L=1.8m R=100m C=27u

La1     a   a10    inductor l=L
Lb1     b   b10    inductor l=L
Lc1     c   c10    inductor l=L

Ra1    a10   a20   resistor r=R
Rb1    b10   b20   resistor r=R
Rc1    c10   c20   resistor r=R

Ra2    a20   a30   resistor r=R
Rb2    b20   b30   resistor r=R
Rc2    c20   c30   resistor r=R

Ca1    a20   gnd   capacitor c=C 
Cb1    b20   gnd   capacitor c=C 
Cc1    c20   gnd   capacitor c=C 

Ra3    a20   a40   resistor r=R
Rb3    b20   b40   resistor r=R
Rc3    c20   c40   resistor r=R

La3    a50   a40   inductor l=L
Lb3    b50   b40   inductor l=L
Lc3    c50   c40   inductor l=L

I1   ila10   gnd   ccvs sensedev="La3" gain1=1
I2   ilb10   gnd   ccvs sensedev="Lb3" gain1=1
I3   ilc10   gnd   ccvs sensedev="Lc3" gain1=1

I4     a30    b30    c30  vd10   vq10   vz10  ABC2DQ0 OMEGA=OMEGA
I5   ila10  ilb10  ilc10  id10   iq10   iz10  ABC2DQ0 OMEGA=OMEGA

I6    pref   qref   vd10  vq10  idref  iqref  IDQREF
I7    vd10   vq10   id10  iq10  idref  iqref  vdout vqout CONTROLLER L=L

I8   vdout  vqout    gnd   a50    b50    c50  DQ02ABC OMEGA=OMEGA

Pwr    pwr   gnd   ila10 ilb10 ilc10 a50 b50 c50 vcvs \
		    func=v(a50)*v(ila10) + v(b50)*v(ilb10) + v(c50)*v(ilc10)
ends

subckt IDQREF  p q vd vq idref iqref
parameter MIN=1

Idref  idref   gnd   p q vd vq vcvs func=2/3*(v(p)*v(vd)+v(q)*v(vq)) / \
                                         max(MIN,v(vd)^2+v(vq)^2)
Iqref  iqref   gnd   p q vd vq vcvs func=2/3*(v(p)*v(vq)-v(q)*v(vd)) / \
                                         max(MIN,v(vd)^2+v(vq)^2)
ends

subckt CONTROLLER vd vq id iq idref iqref vdout vqout
parameters L=1.8m KI=50 KP=20

;Pid   pid  gnd   idref  id  svcvs numer=[KI,KP] denom=[0,1]
Pid   pid  gnd   idref  id  PID KI=KI KP=KP
Id  vdout  gnd   vd gnd  pid gnd   iq gnd vcvs gain1=1 gain2=1 gain3=-OMEGA*L

;Piq   piq  gnd   iqref  iq  svcvs numer=[KI,KP] denom=[0,1]
Piq   piq  gnd   iqref  iq  PID KI=KI KP=KP
Iq  vqout  gnd   vq gnd  piq gnd   id gnd vcvs gain1=1 gain2=1 gain3= OMEGA*L

ends

subckt SOLAR  out

VS    S    gnd  vsource t=0                 v=LOW_IRR  \
                        t=ENV_START         v=LOW_IRR  \
                        t=T_IRR_STOP_SWEEP  v=HIGH_IRR \
                        t=2*ENV_STOP        v=HIGH_IRR \
                        t=3*ENV_STOP        v=LOW_IRR


#ifdef PAN

VT    T    gnd  vsource vdc=25
Pv    pos  neg  T S PV  NS=36*N_SERIES_PV
model PV      nport veriloga="pvMod.va"

#else

Pv    pos  neg  S  gnd  aux  gnd  PV  ; NS=36*N_SERIES_PV
model PV      nport macro=yes evaluate="PvMod"

#endif

Cpv   pos  gnd  capacitor c=100u ic=20*N_SERIES_PV

T1    pos  gnd  xout   gnd  piout  gnd  DCDC
Io    out  gnd  out   xout  cccs   gain1=MULT_PV

Ipi   piout gnd  pos ref PID KP=0.5/2 KI=0.5/2 MIN=0.01 MAX=1-0.01

Clk   clk  gnd  vsource v1=0 v2=VDIG tr=10u tf=10u width=1m \
                        period=CLK_PERIOD

Ipv   ipv  gnd  neg  gnd  ccvs gain1=-1
Mppt  clk  pos  ipv  ref  MPPT VREF=16*N_SERIES_PV

ends

subckt DCDC inp inn outp outn duty egnd
parameter RON=10m

Rp   inp    tp   resistor r=RON
I1    tp   inn   tn   outn   duty  egnd  nport \
                    func1=i(p2)+(1-v(p3))*i(p1) \
                    func2=v(p1)-(1-v(p3))*v(p2) \
                    func3=i(p3)
Rn  outp    tn   resistor r=RON

ends



model MPPT    nport veriloga="mppt.va" verilogatrace=["PwrOld","PwrNew"]

model ABC2DQ0 nport veriloga="abc2dq0.va"
model DQ02ABC nport veriloga="dq02abc.va"
model     PID nport veriloga="pid.va"
