Gden = [1 12 40 64]; 
Gnum = [0 0 0 1]; 
G=tf(Gnum,Gden); 
PLA=pole(G); 


s=tf('s');
GraficoAreasPosiblesMasSingularidades(1.5,0.2,G)
%% PLC OBEJTIVOS DE LUCHO
Zero1=-8; 
PLCObjetivos=[(-2.666+5.205j) (-2.666-5.205j)];
Zero2=5*real(PLCObjetivos(1)); 
Gczeros=(s-Zero1)*(s-Zero2);
Gsingularidades=G*Gczeros; 
Gsingularidades=minreal(Gsingularidades);
p = pole(Gsingularidades);
z = zero(Gsingularidades); 
FaseACompensar = getAngACompensar(PLCObjetivos(1), z, p);

% === Distancia real que deben tener los ceros del PID ===
% Fórmula correcta usando tangente
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tand(FaseACompensar/2)
DistanciaReal=real(PLCObjetivos(1))-DistanciaAlPoloPLC; 
GcPolos=(1/(s-DistanciaReal)^2)
Gsingularidades=Gsingularidades*GcPolos; 
% rlocus(Gsingularidades)
k=8800;
Gc=k*GcPolos*Gczeros;
step(feedback(Gc*G,1))
%% PLC OBJETIVOS MIOS 
Zero1=-8; 
PLCObjetivos=[(-2.7+5j) (-2.7-5j)];
Zero2=4*real(PLCObjetivos(1)); 
Gczeros=(s-Zero1)*(s-Zero2);
Gsingularidades=G*Gczeros; 
Gsingularidades=minreal(Gsingularidades);
p = pole(Gsingularidades);
z = zero(Gsingularidades); 
FaseACompensar = getAngACompensar(PLCObjetivos(1), z, p);

% === Distancia real que deben tener los ceros del PID ===
% Fórmula correcta usando tangente
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tand(FaseACompensar/2)
DistanciaReal=real(PLCObjetivos(1))-DistanciaAlPoloPLC; 
GcPolos=(1/(s-DistanciaReal)^2)
Gsingularidades=Gsingularidades*GcPolos; 
rlocus(Gsingularidades)

Gc=4300*GcPolos*Gczeros;
 step(feedback(Gc*G,1))