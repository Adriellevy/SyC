%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1; 

aux = conv([1 0],[1 1]);    %   Multiplicacion de polinomios
den = conv(aux,[1 2]);      %   Multiplicacion de polinomios

Gs = tf(num, den)  
[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

%% Matrices contolabilidad y observabilidad

Co = ctrb(A,B)  %   Matriz Controlabilidad
Ob = obsv(A,C)  %   Matriz Observabilidad

if rank(Co) == rank(Ob)
    disp('Rank ok')
else
    disp('No se puede usar el metodo')
end

%% Polos de lazo cerrado

ccimg = 1i * 2 .* sqrt(3);  % Parte imaginaria del polo complejo conugado

% Tengo 3 polos de lazo cerrado

PLC = [-2 + ccimg ; -2 - ccimg ; -12]

%% Formula de ackermann

K = acker(A, B ,PLC)

% Tambien funciona:
%
%   K = place(A, B ,PLC)
%

[K(1:end-1) 0]

K(end)
