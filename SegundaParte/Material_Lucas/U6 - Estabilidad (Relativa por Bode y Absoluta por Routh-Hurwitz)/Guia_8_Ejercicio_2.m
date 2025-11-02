%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (s * ( s + 2));
H = 1;

%% Usando sisotool elijo un polo que cumpla
%   Sobrepico M0 < 0.3
%   Tiempo de establecimiento Ts <= 3 seg

%sisotool(Gs);

Gc = ( s + 4)
V_AUX = linspace(0,10,100000);

H4 = figure(4);
rlocus( Gs *Gc *  H, V_AUX );
H5 = figure(5);
Ms = feedback(2 * Gc * Gs,H,-1)
step(Ms);

%   Elijo Polo Lazo Cerrado -1.5 +- j