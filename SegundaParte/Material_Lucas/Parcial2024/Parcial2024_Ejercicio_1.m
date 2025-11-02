%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2 + 4 * s  + 8);
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 15%
%   2) - Tiempo de establecimiento Ts <= 1 seg
%   3) - Capaz de seguir a la rampa

sisotool(Gs);

%   Elijo utilizar un controlador PID
%   Polo en el origen para subir el tipo y que siga a la rampa


%%  Diseño 

Gc = ( s + 1 ) * ( s + 9)/ s;   % Obtenida con sisotool
Kc = 13.176                          % Para cumplir con la condicion 1) y 2)

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


%% Margen de Fase y Margen de ganacia

H5 = figure(5);
margin(Kc * Gc * Gs);