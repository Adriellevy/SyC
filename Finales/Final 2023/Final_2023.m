clear; 
clc; 
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (( s - 1 )*( s + 4 ));

H = 1;

%%
GraficoAreasPosiblesMasSingularidades(2,30,Gs*Gc)
%% Propongo un compensador de adelanto de fase ESTA MAL
Gc=(s-1)/(s+2); 
% rlocus(Gc*Gs)
t = 0:0.01:10;   
step(feedback(17*Gc*Gs,1),t)
%% Propongo un controlador
clc; 
clear; 
close all; 

s = tf('s');

Gs = 1 / (( s - 1 )*( s + 4 ));
Gc=(s-1)/s; 
% rlocus(Gc*Gs);
Gsimplificada=minreal(Gc*Gs);
PLCObjetivos=[-7+i*7.15; -7-i*7.15]
% Diseño la posicion del seguundo zero
FaseACompensar=getAngACompensar(PLCObjetivos(1),0,pole(Gsimplificada));
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tand(180-FaseACompensar);
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLC
Gc=Gc*(s-PosicionReal);
Gsimplificada=minreal(Gc*Gs);
rlocus(Gc*Gs);
%%
step(feedback(10*Gsimplificada,1),3)

%% 
Ms=feedback(6*Gsimplificada,1)
t = 0:0.01:30;   % vector de tiempo
r = t;           % señal rampa

% calcular respuesta
y = lsim(Ms, r, t);


figure;
plot(t, y, 'LineWidth', 2);
hold on;
plot(t, r, '--', 'LineWidth', 1.2);
legend('Salida y(t)', 'Entrada r(t)=t');  

%% Ackerman
[A,B,C,D] = tf2ss([0 0 3],[8 6 1]);

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

PLC=[-0.25+i*0.24;-0.25-i*0.24; -2]
K = acker(Ahat, Bhat ,PLC);
