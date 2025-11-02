%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Transferencia ejemplo 1
s = tf('s');

LG = 10 / (s*(0.5*s + 1))

bode(LG); 
% margin(LG);
grid;

% Funciona cuando SÓLO cambia la fase o SÓLO cambia la ganancia

%% Transferencia ejemplo 2
close all;

LG = 20 / ((0.2*s+1)*(0.5*s+1)*(s+1))

margin(LG); grid;
% Es estable?

%% Transferencia ejemplo 3
close all;

K = 10
% K = 30
% K = 100
LG = K / (s*(s+1)*(s+5))

margin(LG); grid;
% Es estable? Para que valores de K?

%% Transferencia ejemplo 4
close all;

LG = 1.3 * (s+2) / (s^3 + s^2 + 6*s + 1)

margin(LG); grid;

%% Transferencia ejemplo 5 (4 modificado)
% ¿Que pasa si se modifica otra variable, que no afecte únicamente a la
% ganancia, ni únicamente a la fase? (es decir, afecta a ambas partes)
close all;

LG = 1.3 * (s+2) / (s^3 + s^2 + 3*s + 1)

margin(LG); grid;
% En este caso, ¿se gana o se pierde margen de estabilidad?

%% Transferencia ejemplo 6
close all;

LG = 0.38 * (s^2 + 0.1*s + 0.55) / (s*(s+1)*(s^2 + 0.06*s + 0.5))

margin(LG); grid;
% ¿Es bueno el MG obtenido en este control?
% ¿Es bueno el MF obtenido en este control? 


