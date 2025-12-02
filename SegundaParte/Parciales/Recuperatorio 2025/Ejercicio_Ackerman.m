%% Codigo para tipo 1
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

Gden=[1 6 5];
Gnum=[0 0 1]; 
G=tf(Gnum,Gden); 
PLA=pole(G); 


s=tf('s');

% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 15%
%   2) - Tiempo de establecimiento Ts <= 1 seg
%   3) - Capaz de seguir a la rampa, para error nulo al escalon

% sisotool(Gs);

% Calculo de Polo de Lazo Cerrado para la condicion limite
polos = [(-3.5+3j) (-3.5-3j)];
% [polos] = polos_TS_MP(1.99,0.12)
 disp(['Polo 1: ', num2str(polos(1))]);
 disp(['Polo 2: ', num2str(polos(2))]);

%   Elijo usar el -2.5 +- 3i

% Pasar de la funcion trasnferencia al modelo de estado
[A, B, C, D] = tf2ss(Gnum, Gden)  %   Tf a modelo de estados

[b, a] = ss2tf(A,B,C,D);

Gs1 = tf(b, a)

% Matrices contolabilidad y observabilidad

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

% Pasar de modelo de estado a funcion transferencia

[b, a] = ss2tf(A,B,C,D);

PLC = [polos(1); polos(2) ; -30 ]

%  Agrego un polo extra en -12 para que aumente el tipo del sistema

% Formula de ackermann

Ahat = [ A zeros(size(A,1),1); -C 0 ]

Bhat = [B ; 0]

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC)
open_system('Sistema_Seguimiento_Tipo1_Con_Planta_Tipo_1');
% %% Resultado - ( dsp del simulink)
% 
% t = response.Time;
% y = response.Data;       
% info = stepinfo(y,t);
% H1 = figure(1);
% plot(t,y);grid;
% disp(info); % Mostrar los resultados

%% Ackerman tipo 0
%%Consigna Parcial
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G= 1 / (s^2 + 4*s  +16);
H = 1;

% Usando sisotool elijo un polo que cumpla

[num, den] = tfdata(G, 'v');  % 'v' devuelve vectores en lugar de celdas
% step(G)
[A,B,C,D] = tf2ss(num, den);
PLA =polos_TS_MP(1.99,0.12)
%Polos del sistema: p1 = -4.0000+6.0j, p2 = -4.0000-6.0j
PLC=[PLA(1); PLA(2)];%Agrego polo lejano para desestimarlo
Init_cond=0;


A=flip(fliplr(A))
B=flip(B)
C=fliplr(C)

K = acker(A,B,PLC);
%kr=1;
kr = 1 / (C * inv(-A + B*K) * B);
% kr=1/6*10^-4;
% kr=1.638*10^-3; 
% kr=1/kr;
Tiempo_Sim=10;
% === Ejecutar el modelo de Simulink ===
open_system('Sistema_Seguimiento_Tipo1_Con_Planta_Tipo_0');  % opcional, para abrir la ventana
% simOut = sim('Generico_Retroalimentacion_Sin_Aumento_Tipo','ReturnWorkspaceOutputs','on');

