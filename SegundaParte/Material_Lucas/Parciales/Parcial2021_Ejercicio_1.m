%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2 + s * 8);
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 10%
%   2) - Tiempo de establecimiento Ts <= 0.5 seg
%   3) - Capaz de seguir a la rampa

%sisotool(Gs);

%   Elijo utilizar una Red de Adelanto de Fase

%%  Diseño 

Gc = ( s + 8 ) / ( s + 18 );   % Obtenida con sisotool
Kc = 183                       % Para cumplir con la condicion 1) y 2)

%%  Respuesta al escalon

Ms = feedback(Kc * Gc * Gs,H,-1)
H3 = figure(3);
tstep = linspace(0,3,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

H4 = figure(4);
tstep = linspace(0,3,100000);
step(Ms/s,1/s,tstep);grid;

%   Final:
%   1)  Overshoot: 6.08
%   2)  SettlingTime: 0.44
%   3)  Error a la rampa 3 - 2.9 = 0.1 
