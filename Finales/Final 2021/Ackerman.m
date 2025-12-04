%% Constantes
A =100; 
La=100*10^-3; 
Ra=10; 
Jm=0.03;
Bm=0.003; 
Kt=0.4;
Kb=0.4; 
J=0.02;
R=0.1; 
M=5; 
K=40; 
B=0.1;
Kp=1; 
Jeq=Jm+J;


%% Reemplazo las variables 

% A=[0 1 0;...
%     -K/(M+Jeq/R) -(B+Bm/R)/(M+Jeq/R) Kt/(M+Jeq/R);...
%     0 -Kb/(R*La) -Ra/La]
% B=[0 0 1/La]';
% C=[0 1 0];
% D=0;

A=flip(fliplr(A)); 
B=flip(B); 
C=flip(C); 

%%
Co = ctrb(A, B);
rank(Co) %Rank tiene que dar igual que la cantidad de variables de estado del sistema

%% 
Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

PLC=[-0.25+i*0.24;-0.25-i*0.24; -2]
K = acker(Ahat, Bhat ,PLC);

