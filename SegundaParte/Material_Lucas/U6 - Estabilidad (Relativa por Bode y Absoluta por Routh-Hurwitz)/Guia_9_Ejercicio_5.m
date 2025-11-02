%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1; 

den = conv([1/100 1],[1/100 1])
Gs = tf(num, den)  
[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

step(Gs);grid;

%% Matrices contolabilidad y observabilidad

Co = ctrb(A,B)  %   Matriz Controlabilidad
Ob = obsv(A,C)  %   Matriz Observabilidad

%% Pasar de modelo de estado a funcion transferencia

[b, a] = ss2tf(A,B,C,D);
Gs1 = tf(b, a)  


PLC = [-500+600i; -500-600i ; -1000]

%   Agrego un polo extra en -10 para que aumente el tipo del sistema

%% Formula de ackermann

%K = acker(A, B ,PLC)

% Tambien funciona:
%
%   K = place(A, B ,PLC)
%

Ahat = [ A zeros(size(A,1),1); -C 0 ]

Bhat = [B ; 0]

ctr=[Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat]


K = acker(Ahat, Bhat ,PLC)

