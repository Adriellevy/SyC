%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 4 / (( s + 7)*(s + 10));
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 20%
%   2) -Tiempo de establecimiento Ts <= 0.5 seg
%   3) -Error al escalon < 2% ==> KV = 50 1/seg 

%sisotool(Gs);

%   Elijo K = 60 para que cumpla con 1 y con 2
%   Para cumplir con la condicion de error hay que usar una red de retraso
%   de fase
%   Sin RRF el error al escalon es del 58%, para disminuir defino

%% Comprobacion de requisitos con RRF
Zc = 13.6/10000;

Pc = 1/10000

Gc = (s + Zc) / (s + Pc)

%   Al usar una Red de Retraso de Fase el Ts se ve perjudicado entonces uso
%   un controlador PID

%% Controlador PID

%   El primer cero lo utiliza para cnacelar el polo mas lento que es el de
%   Z = 7
%   El polo cae en el origen
%   Tengo que buscar la ubicacion del segundo cero tal que cumpla con la
%   condicion de fase del sistema


Z1 = 7;

Z2 = 49;

Gc = ((s + Z1)*(s + Z2))/s;

%%  Calculo de ganancia

sisotool(Gs, Gc);

%   Elijo K = 1.34

%%  Comprobacion

K = 1.34;

Ms = feedback(K * Gs * Gc ,H,-1);
step(Ms);grid;
stepinfo(Ms)


