%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = 2 /(( s ^ 2 )*( 1 + 0.2 * s ));
H = 1;

V_AUX = linspace(0,8,100000);  %   Aumento limites y resolucion

%% Analizo el lugar de raices de la "transferencia de Lazo Abierto"

H1 = figure(1);
set(H1,'NumberTitle','off','name',' 1)- Lugar de Raices original');
rlocus( G * H, V_AUX ); %  Solo grafico la mitad del lugar de raices 
hold on;                %  Graficar el lugar de raices completo
% rlocus( -G * H );     %  Graficar el lugar de raices completo
grid;                   %  Graficar el lugar de raices completo
hold off;               %  Graficar el lugar de raices completo

% Necesito mover el lugar de raices uso una RAF

%% Calculo del Angulo a compensar utilizando la funcion getAngACompensar

PoloLazoCerrado = -0.75 + 2i;   %   Polo de Lazo Cerrado
PolosGs = pole(G);              %   Polos de Gs
ZerosGs = zero(G);              %   Zeros de Gs

[ang_a_compensar] = getAngACompensar(PoloLazoCerrado, ZerosGs, PolosGs)

PLC_real = -0.75;       %   Polo de Lazo Cerrado
PLC_imaginario = 2;   %   Polo de Lazo Cerrado

ZeroFijo = 0.75;
  
angzero =  atand( PLC_imaginario /  ( ZeroFijo ))

AngPolo = ang_a_compensar + angzero;
Pc = PLC_real - (PLC_imaginario / tand(AngPolo))

%   Da como resultado un ang de -66.3132 deg , este angulo da como resultado
%   un polo en 4.966. Si utilizo este polo no llego a mover el polo de lazo
%   cerrado a -0.75 + 2j , por lo tanto muevo el polo a 5.24 donde con
%   ganancia de 5.22 el polo de lazo cerrado queda en el lugar deseado.

%% Calculo de la Red de Adelanto de Fase

% Zc = -0.75 => para angulo de 90deg con respecto al polo 

% Usando la condicion de fase busco un zero tal que cumpla con el zero que
% se determino

%   P = 5 => arctg( 2 / 4.25) = 25.12 deg
%   P = 0 => 180 - arctg(2/0.75) = 110.33 polo doble
%   180 = 25.12 + 110,33 + 110,33 + ang( Pc) - 90
%   ang( Pc) = 24.22 deg
%   tan ( 24.22 deg ) = 2 / x ==> x = 4.44 ==> Pc = 5.196

Pc = 5.3;
Zc = 0.75;
Gc = ( s + Zc) / ( s + Pc);

H2 = figure(2);
set(H2,'NumberTitle','off','name','2)- Lugar de Raices buscar Kc de RAF');
rlocus(Gc *G, V_AUX );grid;

%   Elijo el valor de KcRAF 

KcRAF = 5.33;

%% Analizo transferencia con RAF grafico de polos y zeros de M(s) con RAF

H3 = figure(3);
set(H3,'NumberTitle','off','name','3)- Polos y zeros de M(s) con RAF');
Ms = feedback(KcRAF*Gc*G,H,-1);
pzmap(Ms);grid;

%% Calculo de la RRF

%   Para aumentar la ganancia 8 veces agrego una RRF 

Zc2 = 8/1000;
Pc2 = 1/1000; 
Gc2 = ( s + Zc2) / ( s + Pc2);

H4 = figure(4);
set(H4,'NumberTitle','off','name','4)- Lugar de Raices buscar Kc de RRF');
rlocus( Gc2 *KcRAF * Gc *G * H, V_AUX );grid;

KcRRF = 1;

%% Verificacion de k con Sisotool para ver Mo y el ts

sisotool(G,Gc2 *KcRAF * Gc );

%% Respuesta al escalon Unitario

% Compurebo que el tiempo de estalbecimieto no cambio al agregar la red de
% retraso de fase

H5 = figure(5);
set(H5,'NumberTitle','off','name','5)- Respuesta al escalon');
Ms = feedback(KcRAF * Gc  *KcRRF*Gc2 * G,H,-1)
step(Ms);grid;
title('Respuesta al escalon');
stepinfo(Ms)

%% Respuesta a la rampa

H6 = figure(6);
set(H6,'NumberTitle','off','name','6)- Respuesta a la rampa');

% Definir el tiempo y la entrada de la rampa
t = 0:0.01:8; % Ajusta el tiempo según sea necesario
rampa = t; % La entrada es una función rampa (r(t) = t)

% Graficar la respuesta a la rampa
lsim(Ms, rampa, t);
grid on;
title('Respuesta a la Rampa');
xlabel('Tiempo (s)');
ylabel('Respuesta del Sistema');
