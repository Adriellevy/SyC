%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = 1 /(( s + 2 )*( s + 3 )*( s + 5 ));
H = 1;

% ts = 0.2

% m0 = 5%

sisotool(G)
% Defino el polo en -20 + j 20

%% Calculo del Angulo a compensar utilizando la funcion getAngACompensar

PoloLazoCerrado = -20 + 20i;   %   Polo de Lazo Cerrado
PolosGs = pole(G);              %   Polos de Gs
ZerosGs = zero(G);              %   Zeros de Gs
[ang_a_compensar] = getAngACompensar(PoloLazoCerrado, ZerosGs, PolosGs)

%% Hay que elehir 4 polos

ccimg = 1i * 20;  % Parte imaginaria del polo complejo conugado

% Tengo 4 polos de lazo cerrado

PLC = [ -20+ccimg ; -20-ccimg ; -100 ; -100 ]

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1; 

aux = conv([1 2],[1 3]);    %   Multiplicacion de polinomios
den = conv(aux,[1 5]);      %   Multiplicacion de polinomios

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

%% Hay que buscar ahat y bhat

Ahat = [ A zeros(size(A,1),1); -C 0 ]

Bhat = [B ; 0]

ctr=[Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat]


K = acker(Ahat, Bhat ,PLC)

