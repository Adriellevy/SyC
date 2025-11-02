%% planteo mi g(s)
num= 5;
den=[0 -0.5 -2];
G=zpk([], den, num);
sisotool(G)
%% armo mi sistema con las dos redes
k=32.57;
den=[0 -5.12 -5.12];
Gt=zpk([], den, k);
sisotool(Gt)
%%  le agrego la red de atraso para bajar el error a la rampa
num=[-0.0178];
den=[0 -0.01 -5.12 -5.12];
Gt=zpk(num, den, 32.67);
sisotool(Gt)

%% acker
num =5;
den = [1 2.5 1 0];
[A B C D]=tf2ss(num, den) % busco mis matrices de modelo de estados
ctrl= [B A*B A*A*B]; 
obs=[C; C*A; C*A*A];
% el rango de las matrices tiene que ser igual a n, y n=dimension A
rank (ctrl)
rank (obs) 
%agrego un cero por lo menos 10 veces mayor a los polos conjugados
PLC = [-3+3*1i -3-3*1i -30];
K= acker(A, B, PLC)
A1=-A(1,1)
A2=-A(1,2)
A3=A(1,3)
K1=K(1,1)
K2=K(1,2)
K3=K(1,3)