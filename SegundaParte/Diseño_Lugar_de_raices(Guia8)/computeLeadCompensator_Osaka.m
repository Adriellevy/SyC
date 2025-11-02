% -------------------------
% computeLeadCompensator_Osaka.m
% -------------------------
function [zc, pc, Kc, Gc] = computeLeadCompensator_Osaka(G, P, angleNeededDeg)
% Implementación del método tipo Osaka para network de adelanto (lead)
% Entradas:
%   G: planta (tf)
%   P: punto deseado (complex)
%   angleNeededDeg: cuánto ángulo debe aportar el compensador en ese punto (grados)
%
% Salidas:
%   zc, pc: ubicaciones sobre el eje real (reales) del cero y polo del lead (z < p)
%   Kc: ganancia multiplicativa del compensador (positiva real)
%   Gc: compensador en tf (Kc*(s+zc)/(s+pc))

% Validar
if imag(P)==0
    warning('P es real. El método Osaka espera polos complejos dominantes. Aun así se procede.');
end

% 1) Calcular ángulo bisector entre PA y PO. 
% PA: línea horizontal hacia la izquierda desde P -> dirección = pi (180deg)
% PO: vector de P hacia el origen: O - P = -real(P) - j imag(P) -> theta_PO
theta_PO = atan2(-imag(P), -real(P)); % rad
theta_PA = pi; % hacia la izquierda
% bisector
theta_bisector = atan2( sin(theta_PA)+sin(theta_PO), cos(theta_PA)+cos(theta_PO) );
% Si denominador 0, fallback promedio:
if isnan(theta_bisector)
    theta_bisector = (theta_PA + theta_PO)/2;
end

% 2) Tomamos alpha = angleNeededDeg (grados). Dividimos en +/- alpha/2 respecto a la bisectriz:
halfAlphaRad = deg2rad(angleNeededDeg/2);

theta1 = theta_bisector + halfAlphaRad;
theta2 = theta_bisector - halfAlphaRad;

% 3) Intersección de cada línea (P + t*[cos(theta), sin(theta)]) con eje real (Im=0)
x1 = lineRealAxisIntersection(P, theta1);
x2 = lineRealAxisIntersection(P, theta2);
% Debemos decidir cuál será cero y cuál polo: para un lead ideal, cero está a la derecha del polo (zc > pc)
% Tomamos zc = max(x1,x2), pc = min(x1,x2)
zc = max([x1 x2]);
pc = min([x1 x2]);

% 4) Crear Gc sin K (transfer function con ganancia 1)
s = tf('s');
Gc_nok = (s - (-zc)) / (s - (-pc)); % si zc dado es positivo real se usa (s+zc) etc.
% Pero nuestras x1,x2 son puntos sobre el real (ya en valor -?); adaptamos: 
% Si zc es real negativo (por ejemplo -1) queremos (s - zc) = (s + 1)
% Para consistencia: definimos zc_loc = real(zc), pc_loc = real(pc)
zc_loc = real(zc); pc_loc = real(pc);
Gc_nok = (s - zc_loc) / (s - pc_loc);

% 5) Calcular Kc por magnitud: |G(P)*Gc(P)*Kc| = 1 => Kc = 1 / (|G(P)*Gc(P)|)
Gp = freqresp(G, P); Gp = squeeze(Gp);
Gcn = freqresp(Gc_nok, P); Gcn = squeeze(Gcn);
magProd = abs(Gp * Gcn);
if magProd == 0
    Kc = NaN;
    warning('Producto de magnitud nulo: revisar ubicaciones.');
else
    Kc = 1 / magProd;
end

% 6) Construir Gc final
Gc = Kc * Gc_nok;

end
