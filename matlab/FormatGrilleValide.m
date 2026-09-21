function ok = FormatGrilleValide(grille)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphael Raphaël Pical
% Verifier une matrice double carree, de taille paire, contenant 0, 1 ou NaN.
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
