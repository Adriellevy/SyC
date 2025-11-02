%Ejercicio 7

GlaNum=[1 1/2]; 

syms s;
densimbolo = s*(s+1)*(s+2);
GlaDen = sym2poly(expand(densimbolo));

GLA=tf(GlaNum,GlaDen); 
% GraficarLugarDeSingularidades(GLA)
% GraficoAreasPosibles(3,30)
% GraficarPolosDeseados(3, 30)

% Polos deseados subamortiguados
[sd, zeta, wn, wd] = GraficarPolosDeseados(3, 30);

% Luego sobre eso, diseñar la red de adelanto
DiseñarRedAdelantoInteractiva(GLA, sd)
