%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

H = 1
Mo = (58 - 50)/50
wd = pi()/1
fact_am_ = sqrt(1/(1 + (pi()/log(Mo))^2))
wn = wd / sqrt(1-fact_am_^2)
K = 10
Gs = (K * wn^2) /(( s^2 + s*2*fact_am_*wn + wn^2 ))

opt = stepDataOptions('StepAmplitude',1);
%step(Gs,opt);

sisotool(Gs)

%PID

 Gc =  0.37642 *(s+20) *(s+1))/s
 
 %%  Respuestas del sistema

Ms = feedback(Gc*Gs,H,-1)

opt = stepDataOptions('StepAmplitude',5);

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