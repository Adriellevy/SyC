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