% EJERCICIO 2
%% armo la tranferencia
num =400;
den= [1 100.04 24 400];

G=tf(num, den);
sisotool (G)

%% planteo el PID
num= [-1.87 -1.87];
den=[0 -0.1-2.8i -0.1+2.8i -100];
Gt=zpk(num, den, 2486.83);
sisotool (Gt) % dieron mal los parametro hay q ver de cambiar los polos
M=feedback(Gt,1);
step(M)

%% 
k=4;
G=zpk([], [-0.1+1.2i -0.1-1.2i], k); % busco el denominador
sisotool (G)

%% ACKER
den=[1 0.25 1.45];
[A B C D]=tf2ss(4, den) % busco mis matrices de modelo de estados
ctrl= [B A*B]; 
obs=[C; C*A];
% el rango de las matrices tiene que ser igual a n, y n=dimension A
rank (ctrl)
rank (obs) 

%planteo mis polos a elección, como aumento de tipo uso hat
Ahat = [A zeros(2,1) ; -C 0];
Bhat = [B ; 0]; 
%agrego un cero por lo menos 10 veces mayor a los polos conjugados
PLC = [-4+6*1i -4-6*1i -40];
K= acker(Ahat, Bhat, PLC)
A1=-A(1,1)
A2=-A(1,2)
K1=K(1,1)
K2=K(1,2)
K3=-K(1,3)
%% acker corregido 
A=[0 1 0; -4 -0.04 0.4;0 -40 -100]
B=[0; 0; 10]
C=[1 0 0]
D=[0]

%chequeo controlabilidad 
ctrl=[B A*B A*A*B A*A*A*B];
rank(ctrl)

%chequeo observabilidad 
obs=[C; C*A; C*A*A; C*A*A*A ]';
rank(obs)

%COMO TENGO QUE AUMENTAR MI ORDEN, HAGO AHAT Y BHAT
Ahat=[A zeros(3,1) ; -C 0];
Bhat=[B;0];

%chequeo controlabilidad con Ahat y Bhat
ctrl=[Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];
rank(ctrl)

%ELIJO MIS POLOS A LAZO CERRADO
PLC=[ -8+8*1i -8-8*1i -80 -80];

khat=acker(Ahat,Bhat,PLC)
A1=-A(1,1)
A2=-A(1,2)
A3=-A(1,3)

Ki=-khat(1,4)
K1=khat(1,1)
K2=khat(1,2)
K3=khat(1,3)