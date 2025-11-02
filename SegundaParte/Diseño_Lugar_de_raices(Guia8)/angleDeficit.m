% -------------------------
% angleDeficit.m
% -------------------------
function angleNeededDeg = angleDeficit(G, P)
% Calcula cuánto ángulo debe aportar el compensador (en grados)
% angle(G(P)) en grados (convención MATLAB: angle devuelve en radianes)
Gval = freqresp(G, P); % evalúa G en s = P
Gval = squeeze(Gval);
angleG = angle(Gval); % rad
angleGdeg = rad2deg(angleG);
% Condición de ángulo para punto del lugar de raíces es: total angle = (2k+1)*180
% asumimos k tal que el deficit esté en rango (-180,180)
% deficit = (180 - angleGdeg) mod 360, ajustado a [-180,180]
raw = 180 - angleGdeg;
angleNeededDeg = mod(raw + 180, 360) - 180; % queda en [-180,180]
% Si se requiere que el compensador aporte ángulo positivo (lead), angleNeededDeg >0
end
