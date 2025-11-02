%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (  s ^ 2 + 4 * s + 8)
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) -    Sobrepico M0 < 15%
%   2) -    Tiempo de establecimiento Ts <= 0.5 seg
%   3) -    Debe seguir a la rampa

%sisotool(Gs);

%% asd
%   Decido utilizar un controlador PID para mover el lugar de raices

Z1 = 13;

Z2 = 1;

KD = 20;

Gc = ( KD *  ( s + Z1 ) * ( s + Z2) ) / s

%%  Respuesta al escalon

Ms = feedback(Gc * Gs ,H,-1)
H3 = figure(3);
tstep = linspace(0,1,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

H4 = figure(4);
tstep = linspace(0,1,100000);
step(Ms/s,1/s,tstep);grid;
