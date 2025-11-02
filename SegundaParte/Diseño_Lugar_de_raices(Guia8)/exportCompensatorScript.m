% -------------------------
% exportCompensatorScript.m
% -------------------------
function fname = exportCompensatorScript(Gc, Kc)
% Guarda un script simple que define el compensador y muestra lazo cerrado
if isempty(Kc)
    error('Falta Kc');
end
fname = ['Compensador_export_', datestr(now,'yyyymmdd_HHMMSS'), '.m'];
fid = fopen(fullfile(pwd,fname),'w');
fprintf(fid, '%% Script exportado por DesignCompensatorUI\n');
fprintf(fid, 's = tf(''s'');\n');
% Extraer numerador/denom de Gc en forma simbólica
[num,den] = tfdata(Gc,'v');
fprintf(fid, 'Gc = tf(%s, %s);\n', mat2str(num), mat2str(den));
fprintf(fid, 'disp(''Gc = ''); Gc\n');
fclose(fid);
end
