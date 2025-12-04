clear; 
clc; 
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (( s - 1 )*( s + 4 ));

H = 1;

%%
GraficoAreasPosiblesMasSingularidades(2,30,Gs)
%% Propongo un controlador PID
Gs = 1 / (( s - 1 )*( s + 4 ));
Gc=(s-1)/s; 
% rlocus(Gc*Gs);
Gsimplificada=minreal(Gc*Gs);
PLCObjetivos=[-7+i*7.15; -7-i*7.15]
%%
FaseACompensar=getAngACompensar(PLCObjetivos(1),0,pole(Gsimplificada));
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tand(180-FaseACompensar);
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLC; 


Gc=Gc*(s-PosicionReal);
Gsimplificada=minreal(Gc*Gs);
rlocus(Gc*Gs);
%%
step(feedback(15*Gsimplificada,1),3)

%% 
Ms=feedback(10*Gsimplificada,1)
t = 0:0.01:30;   % vector de tiempo
r = t;           % señal rampa

% calcular respuesta
y = lsim(Ms, r, t);


figure;
plot(t, y, 'LineWidth', 2);
hold on;
plot(t, r, '--', 'LineWidth', 1.2);
legend('Salida y(t)', 'Entrada r(t)=t');  

%% 
clear; 
clc; 
close all;  % Cierra otras ventanas

s = tf('s');

A =100; 
La=100*10^-3; 
Ra=10; 
Jm=0.03;
Bm=0.003; 
Kt=0.4;
Kb=0.4; 
J=0.02;
R=0.1; 
M=5; 
K=40; 
B=0.1;
Kp=1; 
Jeq=Jm+J;

Ms=A*Kt*R/(s^3*(M*La*R^2+Jeq*La)...
    +s^2*(R^2*M*Ra+B*La+Jeq*Ra+La*Bm)...
    +s*(Ra*Bm+Kt*Kb+La*K+B*Ra)...
    +Kp*Kt*A*R+Ra*K); 
%% Simulacion
step(Ms,20)

t = 0:0.01:0.5;   % vector de tiempo
r = t;           % señal rampa

% calcular respuesta
y = lsim(Ms, r, t);


figure;
plot(t, y, 'LineWidth', 2);
hold on;
plot(t, r, '--', 'LineWidth', 1.2);
legend('Salida y(t)', 'Entrada r(t)=t');
%% Planta control
PolosMs=pole(Ms);
PIDZeros=(s-PolosMs(2))*(s-PolosMs(3)); 
Gc=PIDZeros/s; 
MToto=minreal(Gc*Ms);
rlocus(MToto)
step(feedback(15*MToto,1),0.5)
%
y = lsim(feedback(15*MToto,1), r, t);

figure;
plot(t, y, 'LineWidth', 2);
hold on;
plot(t, r, '--', 'LineWidth', 1.2);
legend('Salida y(t)', 'Entrada r(t)=t');
