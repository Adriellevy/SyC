 %% EJERCICIO 2
num=4;
den=[ 1 1.6 4]; % s^2 + 1.6*s + 4
G=tf(num, den); % armo la transferencia en laplaces con los valores anteriores 
sisotool(G) % te permite ver los parametros de la tranf 
%% PID
Gc= zpk([-5.74 -5.74], [-0.8+1.83i -0.8-1.83i 0], 4*3.0475*2.18);
M=feedback(Gc, 1); % planteo la transferencia total con H=1
sisotool(Gc)
%%
t=0:0.1:100;
figure(1)
lsim(M,t,t)
figure(2)
step(M)
%% ackerman
num =4;
den = [1 1.6 4];
[A B C D]=tf2ss(num, den) % busco mis matrices de modelo de estados
ctrl= [B A*B]; 
obs=[C; C*A];
% el rango de las matrices tiene que ser igual a n, y n=dimension A
rank (ctrl)
rank (obs) 
%planteo mis polos a elección
Ahat = [A zeros(2,1) ; -C 0];
Bhat = [B ; 0]; 
%agrego un cero por lo menos 10 veces mayor a los polos conjugados
PLC = [-5+9*1i -5-9*1i -60];
K= acker(Ahat, Bhat, PLC)