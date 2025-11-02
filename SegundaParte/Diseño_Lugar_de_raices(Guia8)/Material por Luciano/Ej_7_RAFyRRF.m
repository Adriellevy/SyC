%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Datos
Mp = 30; % Sobreelongación porcentual [%]
ts = 3; % Tiempo de establecimiento al 2% [s]

%% Planta
s = tf('s');
Gp = (2*s+1) / ( s*(s+1)*(s+2) );

H = 1; % Realimentación Unitaria
Gc = 1; % Controlador

set(figure,'name','Lugar de Raíces Gp(s)','menubar','figure');
rlocus( Gc * Gp * H );

%% Polos Deseados
% Ubicación de los polos aproximada
[P_LC1, P_LC2] = getPolosDominantes(Mp, ts)

%% Controlador
% % Propongo un RRF - Cancelo el cero y el polo (los del medio, -0.5 y -1)
% cero_c = -1;
% polo_c = -0.5;
% K = 1;
% 
% Gc = K * (s-cero_c)/(s-polo_c);
% 
% set(figure,'name','Lugar de Raíces Gc(s)','menubar','figure');
% rlocus( Gc * Gp * H );
% 
% % Acá ya se que no me va a alcanzar la parte real, no llego a -1.3333
% 
% %% A partir del rlocus defino K
% K = 6.5
% Gc = K * (s-cero_c)/(s-polo_c);
% 
% M = feedback(Gc * Gp, H);
% 
% set(figure,'name','Polos y Ceros - M(s)','menubar','figure');
% pzplot(M);
% 
% step(M)
% stepinfo(M)


%% Controlador
% Propongo un RAF + RRF - Cancelo los dos polos y el cero, dejo únicamente
% el polo del origen, y agrego un polo a la izquierda, de forma tal que
% quede como parte real del LR los -1.33333 que necesito.

% RRF
cero_c1 = -1;
polo_c1 = -0.5;
K1 = 1;

% RAF
cero_c2 = -2;
polo_c2 = 2 * real(P_LC1);
K2 = 1;

Gc1 = K1 * (s-cero_c1)/(s-polo_c1);
Gc2 = K2 * (s-cero_c2)/(s-polo_c2);

set(figure,'name','Lugar de Raíces Gc(s)','menubar','figure');
rlocus( Gc1 * Gc2 * Gp * H );

%% A partir del rlocus defino K
K2 = 6.8 % Podría ser K1 y Gc1, da igual
Gc2 = K2 * (s-cero_c2)/(s-polo_c2);

M = feedback(Gc1 * Gc2 * Gp, H);

set(figure,'name','Polos y Ceros - M(s)','menubar','figure');
pzplot(M);

set(figure,'name','Respuesta al escalón - M(s)','menubar','figure');
step(M);
stepinfo(M)

%% Orden de Ventanas
figure(4);
figure(3);
figure(2);
figure(1);








