%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G1 = 1 / (( s - 1 ) * ( s + 4 ) * s )

K= 0.1;

H = s + 1;

%sisotool(G1, 1 , H)

%% Usando un PID ( TOERICAMENTE DEBERIA SEGUIR LA PARABOLA, PERO NO LO HACE )
%
% Gc =( s + 4 )*(s + 15)/s
%
% Kc = 317
%
%% Usando un PD ( Con un PD seguimiento a la rampa )

Gc =( s + 4 );
Kc = 82.33;

%%  Respuestas del sistema

Ms = feedback(Kc * G1 * Gc,H,-1)

opt = stepDataOptions('StepAmplitude',1);

tstep = linspace(0,5,100000);

H5 = figure(5);
step(Ms,tstep,opt);grid;
title('Respuesta al escalon');
stepinfo(Ms)

H6 = figure(6);
step(Ms/s,1/s,tstep,opt);grid;
title('Respuesta a la rampa');

H7 = figure(7);
step(Ms/(s^2),1/(s^2),tstep,opt);grid;
title('Respuesta a la parabola');

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
plot(tOut, y_ramp -y_res);
title('Error a la rampa')
grid;

%  Error a la parabola

[y_res] = step(Ms/(s^2),tstep);
[y_ramp,tOut] = step(1/(s^2),tstep);
H10 = figure(10);
plot(tOut, y_ramp -y_res);
title('Error a la parabola');
grid;