%% Consigna Parcial
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas
% 
% s = tf('s');
% 
% Gs = 1 / ( s ^ 3 + 12 * s^2 + 40*s + 64);
% H = 1;

Gden=[1 12 40 64];
Gnum=[0 0 0 1]; 
G=tf(Gnum,Gden);
PLA=pole(G)

%COMETNARIO:  LA CONSIGNA ME PIDE SEGUIR UNA RAMPA, TENGO QUE AUMENTAR TIPO
Ts=1.5;
Mp=0.1;
%% Grafico de singularidades del sistema + requerimientos
GraficoAreasPosiblesMasSingularidades(Ts,Mp,G)
% rlocus(G)
%% Diseño por raices 

% GraficoAreasPosiblesMasSingularidades(1,0.15,G)
% Gc=(s-3)^2/s;
% disenar_sistema(G,'Ts',1,'Mp',0.15,'Gc',Gc);
% En el enciso anterior no tenía el polo en el origen por lo que esta mal

% % compensado el sistema. 
% Gden = [1 4 8]; 
% Gnum = [0 0 1]; 
% %Controlado con un sistema PID (dos ceros y un polo para aumentar el tipo),
% %debido a la division de la fase a compensar con dos 

% G=tf(Gnum,Gden); 
% Entonces ahora tengo que diseñar mi sistema con ese polo en el origen como si fuera en la planta. 
Gden_con_polo = [1 12 40 64 0];
Gnum_con_polo = [0 0 0 0 1]; 
%COMENTARIO: Controlado con un sistema PID (dos ceros y un polo(ya agregado para aumentar el tipo),
%debido a la division de la fase a compensar con dos ceros
GPlanta_con_polo=tf(Gnum_con_polo,Gden_con_polo);


PLC= polos_TS_MP(Ts,Mp) % Polos del sistema: p1 = -2.6667 + 3.6383j, p2 = -2.6667 -3.6383j
% COMENTARIO: Los corrigo una unidad a la izquierda y lo mismo en la unidad imaginaria
%%
PLCObjetivos=[PLC(1)-(1.3333-1i*2.3617) PLC(2)-(1.3333+1i*2.3617)] %situo los polos objetivos en -4-+6j para ajustar el lugar de raices y sobre cumplir un poco
%%
FaseACompensar = faseCompensador(Gden_con_polo, [], PLCObjetivos(1),'Cero');
FaseACompensar = 360 - FaseACompensar  %Condicion de fase da 220 con los dos ceros se puede divir en 110
%%
%Para la funcion tangente necesito la fase en radianes. 
FaseACompensarRad = deg2rad(FaseACompensar)/2;
%Divido la fase a compensar en dos para utilizar un PID como controlador
%debido a lo grande que es la fase
DistanciaAlPoloPLCObjetivo = imag(PLCObjetivos(1)) / tan(pi - FaseACompensarRad );
%La distancia de los PLC obejtivos es de 1.815 es distinta a la distancia
%obtenida por paula

% === Posición real donde ubicar los ceros ===
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLCObjetivo;
%La ubicacion en el eje real de los ceros es de -1.78
%%
s=tf('s');
% Gceros=(s-(PLA(2)))*(s-(PLA(3)))/s;
% GTotal=simplify(G*Gceros,'v');

Gceros = (s - PLA(2))*(s - PLA(3)) / s;
GTotal = G * Gceros;

GTotal_simplificada = minreal(GTotal)

rlocus(GTotal)
%Eligo ganancia K = 8.93;
% k=15.5;
% Gcontrol=k*Gceros/s;
% Gden=[1 12 40 64];
% Gnum=[0 0 0 1]; 
% G=tf(Gnum,Gden);
disenar_sistema(G,'Ts',Ts,'Mp',Mp,'Gc',30*Gceros); %chequeo el sistema y me dan la figura con todos los resultados




% %% ===================== EJERCICIO 4 =====================
% % Compensador: doble red de fase
% % Requerimientos: Ts < 1.5 s, Mp < 20%
% % Planta: G(s) = 1/(s^3 + 12s^2 + 40s + 64)
% 
% clc; clear; close all;
% s = tf('s');
% 
% % ----------------- Definición de la planta -----------------
% Gden = [1 12 40 64];
% Gnum = [0 0 0 1];
% G = tf(Gnum, Gden);
% 
% Ts = 1.5;
% Mp = 0.20;
% 
% % ----------------- Zonas requeridas + singularidades -----------------
% GraficoAreasPosiblesMasSingularidades(Ts, Mp, G);
% 
% % ----------------- Cálculo de polos dominantes requeridos -----------------
% PLC = polos_TS_MP(Ts, Mp);      % devuelve polos p1 p2 según Ts y Mp
% p_deseado = PLC(1);             % polo complejo superior
% 
% % ----------------- Fase a compensar -----------------
% % Evaluación del déficit de fase con tu función
% FaseACompensar = faseCompensador(Gden, [], p_deseado, 'Cero');
% FaseACompensar = 360 - FaseACompensar;   % Ajuste típico según tu método
% 
% % Como son dos redes de fase, dividimos por 2
% Fase_por_red = FaseACompensar / 2;
% FaseACompensarRad = deg2rad(Fase_por_red);
% 
% % ----------------- Cálculo del real de los ceros (método de Paula / vos) -----------------
% DistanciaAlPolo = imag(p_deseado) / tan(pi - FaseACompensarRad);
% PosicionRealCero = real(p_deseado) + DistanciaAlPolo;
% 
% % Red 1
% z1 = PosicionRealCero;
% p1c = z1 / 0.1;      % alpha = 0.1 típico para redes lead
% 
% % Red 2 (ligeramente desplazada hacia la derecha)
% z2 = z1 + 1;
% p2c = z2 / 0.1;
% 
% % ----------------- Construcción del compensador completo -----------------
% Gc = (s - z1)/(s - p1c) * (s - z2)/(s - p2c);
% 
% % ----------------- Ajuste de la ganancia por RLocus -----------------
% figure; rlocus(Gc*G); title("RLocus del sistema compensado");
% % Elegís la ganancia moviendo el cursor o poniendo directamente:
% K = 1;     % elegida para cumplir Ts y Mp
% Gcontrol = K * Gc;
% 
% % ----------------- Validación usando TU función final -----------------
% disenar_sistema(G, 'Ts', Ts, 'Mp', Mp, 'Gc', Gcontrol);
% 
% % ----------------- Error al escalón -----------------
% CL = feedback(Gcontrol*G, 1);
% Kv = dcgain(Gcontrol*G);
% e_esc = 1/(1+Kv)
% 
% disp("Error al escalón obtenido:");
% disp(e_esc);
% 
