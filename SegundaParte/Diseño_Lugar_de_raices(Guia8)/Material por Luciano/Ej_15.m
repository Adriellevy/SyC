%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Transferencias
K = 1;
Z1 = 10;
Z2 = 2;

s = tf('s');

Gc = K * (s+Z1)*(s+Z2)/(s);
Gp = 1/(s-20);
G = Gc * Gp;

%% Diseño paso a paso
% Veo el lugar de raíces
fig1=figure(1);
set(fig1,'name','Lugar de Raíces de los polos G(s) con K>0','menubar','figure');
rlocus(10*G);
legend('K>0');
grid;
axis('equal');

M1 = feedback(G, 10);

% Cuánto necesito de prefiltro?
fig2=figure(2);
set(fig2,"name", "Step - Error Verdadero","menubar","figure", "WindowState", "maximized");
step(tf(1), M1);
legend("Escalón","Respuesta al escalón sin compensar", "Respuesta al escalón compensando con Gf(s)=10");
grid;

% Verifico el resultado con el prefiltro
K = 10;
M2 = 10 * M1;

fig3 = figure(3);
set(fig3, "name", "Step - Error Verdadero","menubar","figure", "WindowState", "maximized");
step(tf(1), M1, M2);
legend("Escalón","Respuesta al escalón sin compensar", "Respuesta al escalón compensando con Gf(s)=10");
grid;

%% Orden de ventanas
figure(3);
figure(2);
figure(1);

