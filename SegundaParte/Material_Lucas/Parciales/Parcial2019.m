%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2+ s * 6 + 5);
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 7%
%   2) - Tiempo de establecimiento Ts <= 1.5 seg
%   3) - Capaz de seguir a la rampa

%%sisotool(Gs);

%   Elijo utilizar un controlador PID

%%  Diseño 

Gc = ( ( s + 1 )*( s + 15) ) / s;   % Obtenida con sisotool
Kc = 1.4;

%%  Respuesta al escalon

Ms = feedback(Kc * Gc * Gs,H,-1);
H3 = figure(3);
tstep = linspace(0,5,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

H4 = figure(4);
tstep = linspace(0,5,100000);
step(Ms/s,1/s,tstep);grid;

% Error a la rampa es de 4 - 3.76 = 0.24

%%  Margen de fase y de ganancia

H5 = figure(5);
margin(Kc * Gc * Gs);grid;

%   Margen de ganancia es infinito
%   Margen de fase es de 68 deg o 3.53 rad/s

%% Bode de Ms

H6 = figure(6);
Ms
bode(Ms);grid;

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1; 
den = conv([1 1],[1 5])
Gs = tf(num, den)
[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

%% Matrices contolabilidad y observabilidad

Co = ctrb(A,B)  %   Matriz Controlabilidad
Ob = obsv(A,C)  %   Matriz Observabilidad

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


%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(7, 1.5);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%   Polo de condicion limite -2.667+3.1503i
%   Elijo usar el -3 +- 3i

%% Pasar de modelo de estado a funcion transferencia

[b, a] = ss2tf(A,B,C,D);

PLC = [-3+3i; -3-3i ; -12]

%   Agrego un polo extra en -12 para que aumente el tipo del sistema

%% Formula de ackermann

Ahat = [ A zeros(size(A,1),1); -C 0 ]

Bhat = [B ; 0]

ctr=[Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat]


K = acker(Ahat, Bhat ,PLC)

