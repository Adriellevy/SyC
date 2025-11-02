%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = 10 /(s*(s + 2) * (s + 5));
H = 1;

V_AUX = linspace(0,100,10000);

%% Analizo el lugar de raices de la "transferencia de Lazo Abierto"

H1 = figure(1);
set(H1,'NumberTitle','off','name','Lugar de Raices');
rlocus( G * H, V_AUX );
hold on;
% rlocus( -G * H ); % graficar el lugar de raices completo
grid;
hold off;

%   el polo no pertenece al lugar de raices

%% Planteo Red de Adelanto de Fase

%   Se buscar cancelar el polo en P = -2 por lo tanto planteo RAF 
%   Teniendo en cuenta el calculo del angulo se determina que:
%   Polo de RAF = y el Zero de RAF = -2

ZRAF = 2;       %   Zero de la Red de Adelanto de Fase
PRF =  20;      %   Polo de la Red de Adelanto de Fase
GRAF = (s + ZRAF)/(s + PRF);

H2 = figure(2);
set(H2,'NumberTitle','off','name','Lugar de Raices con RAF');
rlocus( G * H * GRAF );
hold on;
% rlocus( -G * H ); % graficar el lugar de raices completo
grid;
hold off;

% Con rlocus detemrino la ganancia de la Red de Adelanto de Fase

KCRAF = 33.5;   %   Ganancia de Red de Adelanto de Fase 

%% Planteo Red de Retraso de Fase

ZRRF = 15/1000;   %   Zero de la Red de Adelanto de Fase
PRRF = 1/1000;   %   Polo de la Red de Adelanto de Fase
GRRF = (s + ZRRF)/(s + PRRF);

H2 = figure(2);
set(H2,'NumberTitle','off','name','Lugar de Raices con RAF');
rlocus( G * H * GRRF * GRAF * KCRAF );

hold on;
% rlocus( -G * H ); % graficar el lugar de raices completo
grid;
hold off;

% Con rlocus detemrino la ganancia de la Red de Retraso de Fase

KCRRF = 1;   %   Ganancia de Red de Retraso de Fase 

C = KCRAF * KCRRF * GRRF * GRAF;

%% Respuesta al escalon con k

H3 = figure(3);
set(H3,'NumberTitle','off','name','Respuesta al escalon');
sys = feedback(G*C,H,-1)
step(sys);grid;
title('Respuesta al escalon');
stepinfo(sys)
%% sisotool(G , C);
