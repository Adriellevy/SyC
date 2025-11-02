%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

A  = 100;
La = 100e-3;
Ra = 10;
Jm = 0.03;
Bm = 0.003;
Kt = 0.4;
Kb = 0.4;
J = 0.02;
r = 0.1;
M = 5;
K = 40;
b = 0.1;
Kp = 1;

Meq = ((Jm + J)/r^2) + M;

Beq = (Bm/r^2) + b;

num = A * Kt * r;
den = ( s * La + Ra)* r^2 *(s^2 * Meq + s * Beq + K )+ Kt*r*Kp*A + Kt*s*Kp

MS = (num)/(den)

Gs = (A * Kt *r)/(Kt * s * Kb + r^2*( s * La + Ra)*(s^2* Meq +s*Beq+K))

roots([0.01/0.01 1/0.01 0.24/0.01 4/0.01])

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 7%
%   2) - Tiempo de establecimiento Ts <= 30 seg
%   3) - Seguimiento a la rampa

sisotool(Gs,1,Kp);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

Mp = 20;
Ts = 1.5;

[pole1, pole2] = getPolosDominantes(Mp, Ts);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Controlador ( PID )

Kc = 4.53;

Gc = ( s + 3 )^2/s

%%  Respuestas del sistema

Ms = feedback(Kc * Gc * Gs,1,-1)

opt = stepDataOptions('StepAmplitude',1);

tstep = linspace(0,3,100000);

% Respuesta al escalon

H5 = figure(5);
step(Ms,tstep,opt);grid;
title('Respuesta al escalon');
stepinfo(Ms)

%% Modelo de Estado 

A = [ - Ra/La 0 -Kb/(r*La); 0 0 1 ; Kt/(r*Meq) -K/Meq -Beq/Meq]

B = [ 1/La ; 0 ; 0]

C = [ 0 1 0 ]

D = [ 0 ]

% [b, a] = ss2tf(A,B,C,D);
% Gs1 = tf(b, a)  

%% Matrices contolabilidad y observabilidad

Co = ctrb(A,B);  %   Matriz Controlabilidad
Ob = obsv(A,C);  %   Matriz Observabilidad

n = size(A,1);

% Verifico Controlabilidad del sistema
if rank(ctrb(A,B)) == n
    disp('El sistema es Controlable.');
else
    error('El sistema NO es Controlable');
end

% Verifico Observabilidad del sistema
if rank(obsv(A,C)) == n
    disp('El sistema es Observable.');
else
    error('El sistema NO es Observable');
end

%% Pasar de modelo de estado a funcion transferencia

%   Agrego un polo en -50 para subir el tipo de sistema

PLC = [-3+5i; -3-5i ; -20 ; -50]

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC)

%% Ejecutar dsp de obtener el resultado de simulink ( sino da error )

t = response.Time;
y = response.Data;
info = stepinfo(y,t)

% 
%         RiseTime: 0.3062
%     SettlingTime: 1.4082
%      SettlingMin: 0.9783
%      SettlingMax: 1.1419
%        Overshoot: 14.1892
%       Undershoot: 4.2495e-76
%             Peak: 1.1419
%         PeakTime: 0.6832
