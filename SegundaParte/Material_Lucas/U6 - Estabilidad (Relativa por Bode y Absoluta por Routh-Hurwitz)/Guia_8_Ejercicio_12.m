%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 5 /((s^2 - 2*s + 2)*(s + 10))
H = 1;

V_AUX = linspace(0,1000,100000);

Gs = 1/(1 + s/100)^2

sisotool(Gs)

% coeficiente de amortiguamiento = 0.50

% angulo beta = 60 deg

%% Analizo el lugar de raices de la "transferencia de Lazo Abierto"

H1 = figure(1);
set(H1,'NumberTitle','off','name',' 1)- Lugar de Raices original');
rlocus( Gs * H, V_AUX );
hold on;
% rlocus( -G * H ); % graficar el lugar de raices completo
grid;
hold off;

%   Necesito mover el lugar de raices uso una RAF:
%
%   Elijo el polo complejo conjugado ==> 2 +- 3.46
%
%   Compruebo que se pueda compensar
%   ang1 = arctang( 2 / 8.85) = 12.44 deg
%   ang2 = 180 deg - arctan( (2 - 1) / ( 1.15 + 2) ) = 155.3 deg
%   ang3 = 180 deg - arctan( (2 + 1) / ( 1.15 + 2) ) = 125.37 deg
%   180 = ang1 + ang2 + ang3 + angC
%   angC = -113 deg
%   se pueden usar 2 red de adelanto de fase
%   angC1 = AngC2 = 56.30 deg

%% Calculo de la Red de Adelanto de Fase
 
Zc1 = 1;
Pc1 = 10;

Gc1 = ( s + Zc1)/( s + Pc1);

Zc2 = 1;
Pc2 = 10;

Gc2 = ( s + Zc2)/( s + Pc2);

Gc = Gc1 * Gc2;

sisotool(Gs, Gc);

%%

H2 = figure(2);
set(H2,'NumberTitle','off','name','2)- Lugar de Raices buscar Kc de RAF');
rlocus(Gc *Gs * H, V_AUX );grid;

%   Elijo el valor de KcRAF 

KcRAF = 1;
