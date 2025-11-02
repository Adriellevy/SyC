%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (( s - 1 )*( s + 4 ) * s );

% sisotool(Gs)

%% Bloques para usar sisotool ( usando doble realimentacion )

G1 = 1 / (( s - 1 ) * ( s + 4 ))

G2 = 1/s

H1 = tf(1)

H2 = tf(1)

initconfig = sisoinit(6);

initconfig.G1.Value = G1;
initconfig.H1.Value = H1;
initconfig.G2.Value = G2;
initconfig.H2.Value = H2;

%controlSystemDesigner(initconfig)

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 30% 
%   2) - Tiempo de establecimiento Ts <= 2 seg

Mp = 30;
ts = 2;

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(Mp, ts);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%%  Resuelvo realimentacion de velocidad

%   Utilizo una RAF para mover el lugar de raices de la realimentacion de
%   velocidad

Gc2 = 41 * ( s + 4 ) / ( s + 12);

Gaux = feedback( Gs * Gc2 ,1,-1);

Gs2 = Gaux * ( 1 / s );

%%  Resuelvo realimentacion de posicion

%   Utilizo una RAF para mover el lugar de raices de la realimentacion de
%   posicion

Gc1 = 3.66 * ( s + 5 ) / ( s + 10);

%%  Respuesta de mi sistema

Ms = feedback(Gc1*Gs2,1,-1)

H6 = figure(6);
step(Ms);grid;
stepinfo(Ms)
