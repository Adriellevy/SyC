%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

%% Modelo de Estado 

num = 3;

den = [16 25 1 0]

Gs = tf(num, den)

[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

[b, a] = ss2tf(A,B,C,D);

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

PLC = [-3+5i; -3-5i ; -20 ; -50]

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC)

%% Ejecutar dsp de obtener el resultado de simulink ( sino da error )

t = response.Time;
y = response.Data;
info = stepinfo(y,t)
