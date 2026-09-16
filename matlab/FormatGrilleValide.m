function ok = FormatGrilleValide(grille)
% FORMATGRILLEVALIDE Verifier une matrice double carree de taille paire.
% M1 : size, imag et operations matricielles ; M2 : isa ; projet : NaN.
% Implementation avec assistance de Codex, 2026.
ok = false;
if ~isa(grille, 'double')
    return
end
n = size(grille, 1);
if n < 2 || mod(n, 2) ~= 0 || ~isequal(size(grille), [n n])
    return
end
ok = ~any(imag(grille(:)) ~= 0) && ...
    ~any(~isnan(grille(:)) & grille(:) ~= 0 & grille(:) ~= 1);
end
