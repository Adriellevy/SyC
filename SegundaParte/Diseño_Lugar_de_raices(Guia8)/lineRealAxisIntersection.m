% -------------------------
% lineRealAxisIntersection.m
% -------------------------
function x = lineRealAxisIntersection(P, theta)
% Intersección de la recta que pasa por P con ángulo theta con el eje real (Im=0)
xp = real(P); yp = imag(P);
% parametrización: x = xp + t*cos(theta); y = yp + t*sin(theta)
% pedir y=0 -> t = -yp/sin(theta) (si sin(theta)==0, la recta es paralela al eje real -> no intersecta o tangente)
if abs(sin(theta)) < 1e-9
    error('La línea es paralela al eje real (sin(theta)=0). No hay intersección definida.');
end
t = -yp / sin(theta);
x = xp + t * cos(theta);
end
