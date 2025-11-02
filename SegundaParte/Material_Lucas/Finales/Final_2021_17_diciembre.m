%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

K = 1;
fact_am_= 0.4;
wn = 2;
Gs = (K * wn^2) /( s^2 + s*2*fact_am_*wn + wn^2 )
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 20% 
%   2) - Tiempo de establecimiento Ts <= 1 seg
%   3) - Seguimiento a la rampa

%sisotool(Gs)

%% Diseño de controlador PID

Gc = (( s + 0.5 )*( s + 9 ))/s;

Kc = 3.23;

Ms = feedback(Gs * Gc * Kc, 1,-1)

%%  Respuestas del sistema

tstep = linspace(0,40,100000);

opt = stepDataOptions('StepAmplitude',1);

H5 = figure(5);
step(Ms,tstep,opt);grid;
title('Respuesta al escalon');
stepinfo(Ms)

H6 = figure(6);
step(Ms/s,1/s,tstep,opt);grid;
title('Respuesta a la rampa');

%% Errores

% Error al escalon

[y_res, tOut] = step(Ms,tstep);
y_esc = ones(size(tOut));

error_escalon = y_esc - y_res;
H8 = figure(8);
plot(tOut, error_escalon);
title('Error al escalon');
grid;

%  Error a la rampa

[y_res] = step(Ms/s,tstep);
[y_ramp,tOut] = step(1/s,tstep);
H9 = figure(9);
plot(tOut, y_ramp - y_res);
title('Error a la rampa')
grid;
