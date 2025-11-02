%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 2 / ( ( s + 2 ) * (s + 5) );
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 10%
%   2) -Tiempo de establecimiento Ts <= 0.6 seg
%   3) -Error a la rampa  KV > 10

sisotool(Gs);

%   Decido utilizar un controlador PID para mover el lugar de raices

%% Utilizo un controlador PID

%   Cancelo el Polo mas lento por ende Z1 = 2

Z1 = 2;

Z2 = 10;

Gc = ( ( s + Z1 ) * ( s + Z2) ) / s

%   Usando sisotool se puede ver que K = 5

K = 5;

%   Con este PID cumplo 1) y 2)falta comprobar el 

Ms = feedback( K * Gc * Gs , H , -1);   % Funcion trasferencia del sistema

H1 = figure(1);
subplot(2,1,1);
step(Ms);               %   Respueta al Escalon
grid;
subplot(2,1,2);
step(Ms/s - 1/s,1/s);   %   Respuesta a la Rampa
grid;
stepinfo(Ms)            %   Informacion de Respuesta al Escalon

%   Finalmente:
%
%   KD = 5
%
%   KP = 12 * KD = 60
%
%   KI = 20 * KD = 100
%
%   Error del sistema es de 0.025 y se diseño para un error inferior a 0.1

