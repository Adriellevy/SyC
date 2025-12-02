%% Consigna Parcial
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');
% 
% Gs = 1 / ( s ^ 3 + 12 * s^2 + 40*s + 64);
% H = 1;

Gden=[1 6 5];
Gnum=[0 0 1]; 
G=tf(Gnum,Gden);
PLA=pole(G)
%% Diseño
PLCcriticos=polos_TS_MP(1.5,0.07); 
GraficoAreasPosiblesMasSingularidades(1.5,7,G)
%% Ubicar zero

Zero1=-1; 
PLCObjetivos=[(-3.5+3j) (-3.5-3j)];
Gc1Zero=(s-Zero1)/s;
Gsingularidades=G*Gc1Zero; 
Gsingularidades=minreal(Gsingularidades);
p = pole(Gsingularidades);
z = zero(Gsingularidades); 
FaseACompensar = getAngACompensar(PLCObjetivos(1), z, p)

% % === Distancia real que deben tener los ceros del PID ===
% % Fórmula correcta usando tangente
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tand(180-FaseACompensar)
DistanciaReal=real(PLCObjetivos(1))-DistanciaAlPoloPLC
GcZeros=Gc1Zero*(s-DistanciaReal);
Gtot=G*GcZeros; 
Gsingularidades=minreal(Gtot);
rlocus(Gsingularidades)
% 
% Gc=4300*GcPolos*Gczeros;
% step(feedback(2*GcZeros*G,1))
%%
disenar_sistema(G,'Ts',1.5,'Mp',0.07,'Gc',2*GcZeros);
%%
bode(feedback(GcZeros*G,1))