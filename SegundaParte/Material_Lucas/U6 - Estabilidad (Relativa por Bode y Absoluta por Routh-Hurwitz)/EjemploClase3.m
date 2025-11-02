%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = 1 /( s ^ 2 - 2 * s + 4);
H = 1;



% ts = 1

% m0 = 5%
sisotool(G)
% Defino el polo en -20 + j 20
