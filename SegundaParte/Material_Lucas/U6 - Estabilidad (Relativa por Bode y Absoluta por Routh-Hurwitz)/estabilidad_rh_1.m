%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas


%% Transferencia ejemplo 1
s = tf('s');

F = (s+1)*(s+2)

pzmap(F);

%% Transferencia ejemplo 2
close all;

F = (s+3)*(s-4)

pzmap(F);

%% Transferencia ejemplo 3
close all;

F = s^3 + s + 1

pzmap(F);

%% Transferencia ejemplo 4
close all;

F = s^3 + s^2 + 4*s + 4

pzmap(F);

%% Transferencia ejemplo 5
close all;

F = s^4 + 3*s^3 + 3*s^2 + 3*s + 2

pzmap(F);

%% Transferencia ejemplo 5
close all;

G = (2-s)/(2*s);
H = 4 / (s+4);

% Analizo el lugar de raíces de la "transferencia de Lazo 
% Abierto" o "transferencia del lazo"
rlocus(G*H);


