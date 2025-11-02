%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2 + 4 * s  + 8);
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 10%
%   2) - Tiempo de establecimiento Ts <= 1 seg

%sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(10, 1);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%   Limte -4 +- 5.

%%  Diseño 

Gc = ( s + 4 )/(s + 40);   % Obtenida con sisotool
Kc = 155.7

%%  Respuesta al escalon

Ms = feedback(Kc * Gc * Gs,H,-1)
H3 = figure(3);
tstep = linspace(0,2,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

H4 = figure(4);
tstep = linspace(0,3,100000);
step(Ms/s,1/s,tstep);grid;

