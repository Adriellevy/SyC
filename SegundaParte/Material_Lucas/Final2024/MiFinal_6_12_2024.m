%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');


Gact = (10^(15/20))/((s + 0.5)* (s + 2))

Gval = (10^(10/20))/(s + 0.1)

Gtvap = (10^(3/20))/(s+0.01)

Gs = Gact*Gval*Gtvap

%sisotool(Gs)

Gc =  0.0089414 *((s+0.01) *(s+0.1))/s

Ms = feedback(Gc*Gs,1,-1)

opt = stepDataOptions('StepAmplitude',1);

tstep = linspace(0,30,100000);

% Respuesta al escalon

%%
H5 = figure(5);
step(Ms,tstep,opt);grid;
title('Respuesta al escalon');
stepinfo(Ms)

%% raices

roots([ 1 2.61 1.276 0.3371 0.02571  0.0002246 ]);

%% Modelo de estado

num = 25.12;

den = [1 2.61 1.276 0.1125 0.001]

Gs = tf(num, den)

[A, B, C, D] = tf2ss(num, den)

%% Calculo de Polo de Lazo Cerrado para la condicion limite

Mp = 10;    %   Mo <10%
ts = 20;    %   Ts <20 seg

%   Y tmb pide seguimiento a la rampa hay que agregar un integrador

[pole1, pole2] = getPolosDominantes(Mp, ts);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Acker

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

PLC = [-0.2+0.25i; -0.2-0.25i ; -20 ; -25 ; -30]

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC);

k1=K(1)
k2=K(2)
k3=K(3)
k4=K(4)
k5=-K(5)

%% Ejecutar dsp de obtener el resultado de simulink ( sino da error )

t = response.Time;
y = response.Data;
info = stepinfo(y,t)

