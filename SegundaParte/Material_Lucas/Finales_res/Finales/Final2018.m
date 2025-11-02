%% EJERCICIO 1
num=[0.4];
den= [1 0.3 -0.95 -0.4];
G=tf(num,den);
sisotool(G)

%% planteo acker
num =0.4;
den = [1 0.3 -0.95 -0.4];
[A B C D]=tf2ss(num, den) % busco mis matrices de modelo de estados
ctrl= [B A*B A*A*B]; 
obs=[C; C*A; C*A*A];
% el rango de las matrices tiene que ser igual a n, y n=dimension A
rank (ctrl)
rank (obs) 
%agrego un cero por lo menos 10 veces mayor a los polos conjugados
PLC = [-2+2.73*1i -2-2.73*1i -20];
K= acker(A, B, PLC)
A1=-A(1,1)
A2=-A(1,2)
A3=-A(1,3)
K1=K(1,1)
K2=K(1,2)
K3=K(1,3)

%% EJERCICIO 2
numGt=[];
denGt=[0 -50];
Gt=zpk(numGt, denGt, 1850);
M=feedback(Gt,1);
step(M)
sisotool(Gt)