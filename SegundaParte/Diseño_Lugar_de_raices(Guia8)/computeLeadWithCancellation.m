function [zc, pc, Kc, Gc, desc] = computeLeadWithCancellation(G, P, cancelPoint, cancelType)
% Crea una red de adelanto que intenta cancelar un cero o polo de G y luego diseña el lead alrededor de P.
% Inputs:
%   G: tf planta
%   P: punto deseado (si ~[], se usa cancelPoint directo)
%   cancelPoint: si P vacio, real location to cancel. Si vacío y P dado, busca el cero/polo más cercano.
%   cancelType: 'Cero' o 'Polo'
% Outputs:
%   zc, pc, Kc, Gc, desc

% 1) localizar el cero/polo de la planta más cercano al cancelPoint o a P proyectado en eje real
[numG,denG] = tfdata(G,'v');
pz = pole(G); zz = tzero(G); % zeros y polos (control toolbox)
if isempty(cancelPoint) && ~isempty(P)
    % proyectar P sobre eje real para cancelar punto cercano
    targetReal = real(P);
else
    targetReal = cancelPoint;
end

% elegir lista según cancelType
if strcmpi(cancelType,'Cero')
    candidates = zz;
else
    candidates = pz;
end
if isempty(candidates)
    error('La planta no tiene %s para cancelar.', cancelType);
end
% buscar el más cercano en valor absoluto
[~, idx] = min(abs(real(candidates) - targetReal));
plantPoint = candidates(idx);

% Para cancelar, colocamos un cero o polo (dependiendo) en la misma posición.
% Para lead (compensador) normalmente tenemos un cero a la derecha del polo.
% Estrategia: colocamos UNO de los ceros/polos del compensador exactamente en plantPoint
% y ubicamos el otro (contrapartida) cerca en el eje real (según ratio a buscado).
% Para ejemplo sencillo: fijamos zc = plantPoint (si cancelamos un cero de planta lo pondremos en cero de comp)
% y colocamos pc = zc - delta (delta positivo pequeño) (o viceversa dependiendo de la convención)
delta = max(0.1, abs(real(plantPoint))*0.05 + 0.05); % separación mínima
if strcmpi(cancelType,'Cero')
    % queremos que Gc tenga un polo en plantPoint para cancelar el cero de planta? 
    % Para cancelar un cero de planta se necesita colocar un polo en mismo sitio en el compensador.
    pc = real(plantPoint);
    zc = pc + delta; % cero a la derecha (lead: z>p)
else
    % cancelar un polo de planta colocando un cero del compensador en la misma ubicación
    zc = real(plantPoint);
    pc = zc - delta; % polo a la izquierda
end

% Si P dado, ajustar ángulo necesario sumando contribución de este par:
if ~isempty(P)
    % calcular ángulo que G + (zc,pc) aportan en P
    s = tf('s');
    Gc_tmp = (s - zc) / (s - pc);
    angleNeeded = angleDeficit(G * 1, P); % ángulo que falta sin compensador
    % la pareja zc/pc ya aporta cierto ángulo; ajustamos delta para aproximar angleNeeded
    % Simple: ajustar signo y tamaño de delta para aproximar. Hacemos una búsqueda sencilla sobre delta.
    bestDelta = delta; bestErr = inf; bestZ = zc; bestP = pc; bestK = 1;
    deltas = linspace(delta*0.2, delta*5, 30);
    for d = deltas
        if strcmpi(cancelType,'Cero')
            ptest = real(plantPoint);
            ztest = ptest + d;
        else
            ztest = real(plantPoint);
            ptest = ztest - d;
        end
        Gc_test = (s - ztest) / (s - ptest);
        % ángulo aportado por Gc en P:
        angGc = rad2deg(angle(freqresp(Gc_test,P)));
        angG = rad2deg(angle(freqresp(G,P)));
        totalAng = angG + angGc;
        deficit = mod(180 - totalAng + 180,360) - 180;
        if abs(deficit) < bestErr
            bestErr = abs(deficit);
            bestDelta = d;
            bestZ = ztest; bestP = ptest;
        end
    end
    zc = bestZ; pc = bestP;
end

% construir Gc sin K y calcular K
s = tf('s');
Gc_nok = (s - zc) / (s - pc);
% Si P dado: obtener K por magnitud
if ~isempty(P)
    Gp = squeeze(freqresp(G,P));
    Gcn = squeeze(freqresp(Gc_nok,P));
    magProd = abs(Gp * Gcn);
    if magProd==0
        Kc = NaN;
    else
        Kc = 1/magProd;
    end
else
    Kc = 1;
end
Gc = Kc * Gc_nok;
desc = sprintf('lead cancel %s at %.4f (delta=%.3f)', cancelType, real(plantPoint), abs(zc-pc));
end
