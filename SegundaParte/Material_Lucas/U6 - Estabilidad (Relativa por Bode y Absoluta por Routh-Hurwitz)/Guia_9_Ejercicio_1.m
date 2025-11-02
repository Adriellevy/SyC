%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Pasar de la funcion trasnferencia al modelo de estado

num = [23.45, 7.18]; 
den = [1, 6.25, 28.32, 7.18];
Gs = tf(num, den)  
[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

%% Matrices contolabilidad y observabilidad

Co = ctrb(A,B)  %   Matriz Controlabilidad
Ob = obsv(A,C)  %   Matriz Observabilidad

%% Pasar de modelo de estado a funcion transferencia

[b, a] = ss2tf(A,B,C,D);
Gs1 = tf(b, a)  