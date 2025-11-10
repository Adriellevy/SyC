%Ejercicio 7

Den = sym2poly(expand((s+2)*(s+5)));
Num = [2];
G = tf(Num, Den);
% GraficarLugarDeSingularidades(GLA)
% GraficoAreasPosibles(3,30)
% GraficarPolosDeseados(3, 30)
DesignCompensatorUI(G);
