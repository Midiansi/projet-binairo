function [grid, valid] = SolveBinairo(grid)
% SOLVEBINAIRO Resoudre une grille par deductions puis essais recursifs 0, 1.
% Interface et ordre de SolveBinairoHeader.m (8.9.2026) et MATLAB 2, p. 1.
% La taille est paire selon P00, p. 27 : le mot "odd" de l'en-tete est une coquille.
% En cas d'echec, renvoyer la derniere grille partielle et valid = false,
% comme annonce dans l'en-tete fourni. Aucune unicite de solution n'est promise.
% Implementation avec assistance de Codex, 2026.
valid = false;
if ~GrilleBinairoValide(grid)
    return
end
n = size(grid, 1);
[grid, ok] = DirectValues(grid, n);
if ~ok
    return
end
premiere = find(isnan(grid), 1, 'first');
if isempty(premiere)
    valid = true;
    return
end
[r, c] = ind2sub([n n], premiere);
baseEssais = grid;
if CheckValidMove(baseEssais, r, c, 0, n)
    essai = baseEssais;
    essai(r, c) = 0;
    [grid, valid] = SolveBinairo(essai);
    if valid
        return
    end
end
if CheckValidMove(baseEssais, r, c, 1, n)
    % Repartir de la meme grille avant l'essai : abandonner la branche zero.
    essai = baseEssais;
    essai(r, c) = 1;
    [grid, valid] = SolveBinairo(essai);
end
end
