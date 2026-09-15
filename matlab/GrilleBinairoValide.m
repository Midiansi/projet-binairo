function ok = GrilleBinairoValide(grille)
% GRILLEBINAIROVALIDE Verifier toutes les regles, y compris celles des grilles deja completes.
% Implementation avec assistance de Codex, 2026.
ok = FormatGrilleValide(grille);
if ~ok
    return
end
n = size(grille, 1);
ok = all(arrayfun(@(k) CheckVectorOk(grille(k, :), n) && ...
    CheckVectorOk(grille(:, k), n), 1:n));
if ~ok
    return
end
lignesCompletes = grille(all(~isnan(grille), 2), :);
colonnesCompletes = grille(:, all(~isnan(grille), 1)).';
ok = size(unique(lignesCompletes, 'rows'), 1) == size(lignesCompletes, 1) && ...
    size(unique(colonnesCompletes, 'rows'), 1) == size(colonnesCompletes, 1);
end
