%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

K = 10^(10/20);
fact_am_= 0.4;
wn = 2;
Gs = (K * wn^2) /( s^2 + s*2*fact_am_*wn + wn^2 )
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 20% 
%   2) - Tiempo de establecimiento Ts <= 1 seg
%   3) - Seguimiento a la rampa

sisotool(Gs)

%% Diseño de controlador PID

Gc = (( s + 1 )*( s + 8 ))/s

%%  Respuesta al escalon

Ms = feedback(Gc * Gs,H,-1)
H5 = figure(5);
tstep = linspace(0,2,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

Ms = feedback(Gc * Gs,H,-1);
H6 = figure(6);
tstep = linspace(0,2,100000);
step(Ms/s,1/s,tstep);grid;

%%  Error a la rampa

tstep = linspace(0,5,100000);
[y_res] = step(Ms/s,tstep);
[y_ramp,tOut] = step(1/s,tstep);
H7 = figure(7);
plot(tOut, y_ramp -y_res);
grid;

%%  Error al escalon

tstep = linspace(0,5,100000);
[y_res] = step(Ms,tstep);
y_esc = ones(size(y_res));
H8 = figure(8);
plot(tOut, y_esc -y_res);
grid;
