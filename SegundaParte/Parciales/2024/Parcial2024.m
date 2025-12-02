%% Parcial 2024
clc;
clear;
Gden = [1 4 8]; 
Gnum = [0 0 1]; 
%Controlado con un sistema PID (dos ceros y un polo para aumentar el tipo),
%debido a la division de la fase a compensar con dos 
G=tf(Gnum,Gden); 
PLA=pole(G);

%% Diseño por lugar de raices
PLC= polos_TS_MP(1,0.15); % Polos del sistema: p1 = -4.0000+6.6239j, p2 = -4.0000-6.6239j
PLCObjetivos=[PLC(1)-(1+1i*1.6239) PLC(2)-(1-1i*1.6239)]; %%%Los corrigo uno iz, uno derecha
%Este objeitvo es porque necesito hacer que el lugar de raices pase para
%cumplir las condiciones de diseño solicitadas.

% === Fase a compensar (en grados) ===
FaseACompensar = faseCompensador(Gden, Gnum, PLCObjetivos(1));  %Condicion de fase da 220, la separo con dos ceros del PID

% === Convertimos a radianes ===
FaseACompensarRad = deg2rad(FaseACompensar);

% === Distancia real que deben tener los ceros del PID ===
% Fórmula correcta usando tangente
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tan( pi - FaseACompensarRad/2 );

% === Posición real donde ubicar los ceros ===
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLC;

s=tf('s');
Gc=(s-PosicionReal)^2/s;
GPlanta=simplify(G*Gc,'v'); 
% pzmap(GPlanta); 
rlocus(G*Gc); 
disenar_sistema(G,'Ts',1,'Mp',0.15,'Gc',Gc); %chequeo el sistema y me dan la figura con todos los resultados

% sisotool(G)
% zmap(G)
%TODO hacer funcion para calcularme fase necesaria
%ver de compensar con dos ceros en vez de cancelar singularidades por ahi. 
% Gc = k(s+3,97)^2/s; Raices de la clase
%% Diseño por raices 2da version

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
Gden_con_polo = [1 4 8 0]; 
Gnum_con_polo = [0 0 0 1]; 
%Controlado con un sistema PID (dos ceros y un polo(ya agregado para aumentar el tipo),
%debido a la division de la fase a compensar con dos 
GPlanta_con_polo=tf(Gnum_con_polo,Gden_con_polo); %

PLC= polos_TS_MP(1,0.15); % Polos del sistema: p1 = -4.0000+6.6239j, p2 = -4.0000-6.6239j

%Los corrigo una unidad a la izquierda y lo mismo en la unidad imaginaria
PLCObjetivos=[PLC(1)-(1+1i*1.6239) PLC(2)-(1-1i*1.6239)]; 

FaseACompensar = faseCompensador(Gden_con_polo, [], PLCObjetivos(1),'Cero');
FaseACompensar = 360 - FaseACompensar;  %Condicion de fase da 219.9° distinto a 203

%Para la funcion tangente necesito la fase en radianes. 
FaseACompensarRad = deg2rad(FaseACompensar)/2;
%Divido la fase a compensar en dos para utilizar un PID como controlador
%debido a lo grande que es la fase
DistanciaAlPoloPLCObjetivo = imag(PLCObjetivos(1)) / tan(pi - FaseACompensarRad );
%La distancia de los PLC obejtivos es de 1.815 es distinta a la distancia
%obtenida por paula

% === Posición real donde ubicar los ceros ===
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLCObjetivo;
%La ubicacion en el eje real de los ceros es de -3.18

s=tf('s');
Gceros=(s-PosicionReal)^2;
GTotal=simplify(GPlanta_con_polo*Gceros,'v');
%rlocus(GTotal)
%Eligo ganancia K = 8.93;
Gcontrol=8.93*Gceros/s;
Gden = [1 4 8]; 
Gnum = [0 0 1];
G=tf(Gnum,Gden); 
disenar_sistema(G,'Ts',1,'Mp',0.15,'Gc',Gcontrol); %chequeo el sistema y me dan la figura con todos los resultados




%% Ejercicio 2
[num, den] = tfdata(G, 'v');  % 'v' devuelve vectores en lugar de celdas
% step(G)
[A,B,C,D] = tf2ss(num, den);
PLA =polos_TS_MP(1,0.15);
%Polos del sistema: p1 = -4.0000+6.6239j, p2 = -4.0000-6.6239j
PLC=[-5+1i*5; -5-1i*5]
Init_cond=0;


A=flip(fliplr(A));
B=flip(B);
C=fliplr(C);

k = acker(A,B,PLC);
kr = 1 / (C * inv(-A + B*k) * B);

Tiempo_Sim=10;
% === Ejecutar el modelo de Simulink ===
open_system('Control_Generico');  % opcional, para abrir la ventana
% simOut = sim('Generico_Retroalimentacion_Sin_Aumento_Tipo','ReturnWorkspaceOutputs','on');





