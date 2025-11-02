%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 3 / ( ( s + 1 ) * ( s + 5 ) * ( s + 10 ) );
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 10%
%   2) - Tiempo de establecimiento Ts <= 2.5 seg
%   3) - Capaz de seguir a la rampa

sisotool(Gs);

%   Elijo utilizar un proporcional

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(10, 2.5);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%%  Respuesta al escalon

Kc = 35

Ms = feedback(Kc * Gs,H,-1)
H3 = figure(3);
tstep = linspace(0,3,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%   Final:
%   1)  Overshoot: 8.3571
%   2)  SettlingTime: 1.7192
