%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2+ s * 6 + 5);
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 10%
%   2) - Tiempo de establecimiento Ts <= 2 seg
%   3) - Capaz de seguir a la rampa

%sisotool(Gs);

%   Elijo utilizar un controlador PI
%   Polo en el origen
%   Zero en -1

%%  Diseño 

Gc = ( s + 1 )/ s;   % Obtenida con sisotool
Kc = 17              % Para cumplir con la condicion 1) y 2)

%%  Respuesta al escalon

Ms = feedback(Kc * Gc * Gs,H,-1);
H3 = figure(3);
tstep = linspace(0,2,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

H4 = figure(4);
tstep = linspace(0,3,100000);
step(Ms/s,1/s,tstep);grid;

%   Error a la rampa es de 3 - 2.71 = 0.29 % Cumplo con la condicion 3

%   Final:
%   1)  Overshoot: 9.1132
%   2)  SettlingTime: 1.4443
%   3)  Error a la rampa 0.29 = 29%