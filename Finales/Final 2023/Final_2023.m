clear; 
clc; 
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (( s - 1 )*( s + 4 ))

H = 1;

%%
GraficoAreasPosiblesMasSingularidades(2,30,Gs)
%% Propongo un compensador de adelanto de fase
Gc=(s-1)/(s+2); 
% rlocus(Gc*Gs)
t = 0:0.01:10;   
step(feedback(17*Gc*Gs,1),t)