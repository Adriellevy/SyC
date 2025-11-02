%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 /(s*(s + 1)*(s + 4));
H = 1;

%   Sobrepico M0 < 15 %
%   Margen de ganancia MG >= 3
%   Tiempo de establecimiento Ts <= 1 seg

V_AUX = linspace(0,10,100000);

%% Analizo el lugar de raices de la "transferencia de Lazo Abierto"

H1 = figure(1);
set(H1,'NumberTitle','off','name',' 1)- Lugar de Raices original');
rlocus( Gs * H, V_AUX );
hold on;
% rlocus( -G * H ); % graficar el lugar de raices completo
grid;
hold off;

% necesito mover el lugar de raices uso una RAF

%   P =  0 => ang = 180 - arctg()
%   P = -1 => ang = 180 - 
%   P = -4

sisotool(Gs);

%% Calculo de la Red de Adelanto de Fase

Pc = 5.24; 
Zc = 0.75;
Gc = ( s + Zc) / ( s + Pc);

H2 = figure(2);
set(H2,'NumberTitle','off','name','2)- Lugar de Raices buscar Kc de RAF');
rlocus(Gc *G * H, V_AUX );grid;

%   Elijo el valor de KcRAF 

KcRAF = 5.22;

