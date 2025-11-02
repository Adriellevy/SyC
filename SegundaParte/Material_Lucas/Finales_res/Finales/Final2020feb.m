%% ejercicio 3
Gc= zpk([], [-0.01 -0.5 -0.1 -2], 25.04);
sisotool(Gc)
%% sistema con PID
Gt= zpk([], [-0.5 -2 0], 0.256);
sisotool(Gt)
%% transferencia a lazo abierto
num=25.04;
den=[1 2.61 1.276 0.1125 0.001];
G=tf(num,den);
sisotool(G)

%% ackerman
num=25.04;
den=[1 2.61 1.276 0.1125]; % desprecio el polo en 0.001 muy chico
[A B C D]=tf2ss(num, den) % busco mis matrices de modelo de estados

Ahat=[A zeros(3,1) ; -C 0];
Bhat=[B;0];
PLC=[ -6+8*1i -6-8*1i -60 -60];

%chequeo controlabilidad 
ctrl=[B A*B A*A*B];
rank(ctrl)

%chequeo observabilidad
obs=[C; C*A; C*A*A ]';
rank(obs)


khat=acker(Ahat,Bhat,PLC)
A1=-A(1,1)
A2=-A(1,2)
A3=-A(1,3)
Ki=-khat(1,4)
K1=khat(1,1)
K2=khat(1,2)
K3=khat(1,3)