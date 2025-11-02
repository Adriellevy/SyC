function Gc_comb = combineCompensators(listComp)
% listComp: cell array de structs con campo .Gc (tf)
Gc_comb = 1;
for k=1:numel(listComp)
    c = listComp{k};
    if isfield(c,'Gc') && ~isempty(c.Gc)
        Gc_comb = series(Gc_comb, c.Gc);
    end
end
end
