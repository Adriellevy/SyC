%% EJERCICIO 2
num=[];
den=[0 0.79 -3.79];
G=zpk(num, den, 1);

%% otros PLC (3+-5,79) y desprecio los polos alejados de la red de adelanto
Gt=zpk([-6.57], [0 0.79], 2.01*6.63);
sisotool(Gt)

%% acker
[A,B,C,D]=tf2ss(1, [1 3 -3 0])

% como el denominador llega a s^3 debo llegar hasta 2 A
ctrl=[B A*B A*A*B];
rank(ctrl)
obs=[C; C*A; C*A*A];
rank(obs)

J=[-3+i*5.8 -3-i*5.8 -30];
k=acker(A,B,J)