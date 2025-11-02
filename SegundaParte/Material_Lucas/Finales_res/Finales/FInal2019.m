%% EJERCICIO 2
num=3;
den=[16 10 1 0];
G=tf(num,den);
sisotool(G)
rlocus(G);

%% armo PD
num= [1 0.125];
den=1;
PD=tf(num, den);

%% armo la planta con PD
den=[0 -0.5];
Gt=zpk([],den,0.085);
sisotool(Gt)

%% respuesta a la rampa
M=feedback(Gt, 1); % planteo la transferencia total con H=1
t=0:0.1:100;
lsim(M,t,t)

%% EJERCICIO 3 ACKER
num=3/16;
den=[1 0.625 0.0625 0];
%busco las matrices
[A, B, C, D]=tf2ss(num, den)
ctrl= [B A*B A*A*B]; 
obs=[C; C*A; C*A*A];
% el rango de las matrices tiene que ser igual a n, y n=dimension A
rank (ctrl)
rank (obs) 
%armo vector de polos
% como no necesito aumentar de tipo no uso ahat
J=[-4+4*1i -4-4*1i -80];
K=acker(A,B,J)
A1=-A(1,1)
A2=-A(1,2)
A3=-A(1,3)
K1=K(1,1)
K2=K(1,2)
K3=K(1,3)

