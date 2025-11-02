%% planteo mi g inicial
g=zpk([], [0 -0.25 -0.5], 0.375);
sisotool(g)
%% PD agrego un cero pq ya es de tipo 1
Gc= zpk([-0.18], [0 -0.5 -0.25], 1.3278*0.178);% modifico la ganacia para cambiar PLC
M=feedback(Gc, 1); % planteo la transferencia total con H=1
sisotool(Gc)
%%
t=0:0.1:100; 
figure(1)
lsim(M,t,t)
figure(2)
step(M);

%% EJERCICIO 3 ACKER
num=0.375;
den=[1 0.75 0.125 0];
%busco las matrices
[A, B, C, D]=tf2ss(num, den)
ctrl= [B A*B A*A*B]; 
obs=[C; C*A; C*A*A];
% el rango de las matrices tiene que ser igual a n, y n=dimension A
rank (ctrl)
rank (obs) 
%armo vector de polos
% como no necesito aumentar de tipo no uso ahat
J=[-2-2.33i -2+2.33i -20];
K=acker(A,B,J)
A1=-A(1,1)
A2=-A(1,2)
A3=-A(1,3)
K1=K(1,1)
K2=K(1,2)
K3=K(1,3)