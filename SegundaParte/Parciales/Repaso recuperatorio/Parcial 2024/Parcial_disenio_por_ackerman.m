%%Consigna Parcial
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G= 1 / ( s ^ 3 + 12 * s^2 + 40*s  +64);
H = 1;

%% Usando sisotool elijo un polo que cumpla

[num, den] = tfdata(G, 'v');  % 'v' devuelve vectores en lugar de celdas
% step(G)
[A,B,C,D] = tf2ss(num, den);
PLA =polos_TS_MP(1.5,0.10)
%Polos del sistema: p1 = -4.0000+6.0j, p2 = -4.0000-6.0j
PLC=[PLA(1); PLA(2); -30];%Agrego polo lejano para desestimarlo
Init_cond=0;


A=flip(fliplr(A));
B=flip(B);
C=fliplr(C);

K = acker(A,B,PLC);
% kr = 1 / (C * inv(-A + B*k) * B);
% kr=1/6*10^-4;
kr=1.638*10^-3; 
kr=1/kr;
Tiempo_Sim=10;
% === Ejecutar el modelo de Simulink ===
open_system('Sistema_Seguimiento_Tipo1_Con_Planta_Tipo_0');  % opcional, para abrir la ventana
% simOut = sim('Generico_Retroalimentacion_Sin_Aumento_Tipo','ReturnWorkspaceOutputs','on');



%% Resultado - ( dsp del simulink)

t = response.Time;
y = response.Data;
info = stepinfo(y,t);
H1 = figure(1);
plot(t,y);grid;
disp(info); % Mostrar los resultados
