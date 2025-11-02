%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = (2 * s + 1) / (s * (s + 1) * (s + 2));
H = 1;

%% Usando sisotool elijo un polo que cumpla
%   Sobrepico M0 < 0.3
%   Tiempo de establecimiento Ts <= 3 seg

sisotool(Gs);

%   Elijo Polo Lazo Cerrado -1.5 +- j3

%% Comproar el angulo de compensacion:

% Angulo de los polos:

%   P =  0 
Ang0 = 180 - atand(3 / 1.5)
%   P = -1 
Ang1 = 180 - atand(3 / 1.5 - 1)
%   P = -2 
Ang2 = atand(3 / 2 - 1.5)

AngP = Ang0 + Ang1 +Ang2

% Angulo de los Zeros

%   Z = 0.5

AngZ = atand(3 / 1.5 - 0.5)

AngC = 180 - AngP + AngZ

% Angulo de Compensacion es - 15.25 deg se puede compenzar con RAF

%   -15.25 deg < 80 deg uso Red de Adelanto de Fase

%% Calculo de la Red de Adelanto de Fase

% Cancelo el polo en -2 Ang2

Polos = Ang0 + Ang2

Zeros = AngZ

AngPC =  180 - Polos + Zeros

%% Angulo del Pc = -15.255 deg

Pc = 9
Zc = 2

Gc = (s + Zc)/(s + Pc)

rlocus(Gs *Gc * H );grid;

%%sisotool(Gs , Gc);

%% Respuesta al escalon Unitario

% Compurebo que el tiempo de estalbecimieto no cambio al agregar la red de
% retraso de fase

H5 = figure(5);
set(H5,'NumberTitle','off','name','5)- Respuesta al escalon');
Ms = feedback(Gc*Gs,H,-1)
step(Ms);grid;
title('Respuesta al escalon');
stepinfo(Ms)
