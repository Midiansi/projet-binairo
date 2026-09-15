function ok = FormatGrilleValide(grille)
% FORMATGRILLEVALIDE Verifier la representation : matrice double carree, paire, avec 0, 1 ou NaN.
% Les contradictions entre valeurs sont verifiees par GrilleBinairoValide.
% Implementation avec assistance de Codex, 2026.
ok = isa(grille, 'double') && isreal(grille) && ismatrix(grille) && ...
    size(grille, 1) >= 2 && size(grille, 1) == size(grille, 2) && ...
    mod(size(grille, 1), 2) == 0;
if ok
    ok = all(isnan(grille(:)) | grille(:) == 0 | grille(:) == 1);
end
end
