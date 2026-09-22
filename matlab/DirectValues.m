function [grid, ok] = DirectValues(grid, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphaël Pical
% Appliquer les deductions certaines jusqu'a stabilisation ou contradiction.
% 1) Direct solution:
%   Do until no grid change or error
%     find next empty cell
%     check if empty cells can get '0' and/or '1'
%     if both possible -> ignore and next cell
%     if none possible -> error -> exit and backtrack
%     if '0' or '1' *exclusively* possible -> set and next cell
%   repeat
%
% Uses
%    CheckValidMove()
ok = isa(n, 'double') && numel(n) == 1 && ...
    GrilleBinairoValide(grid) && n == size(grid, 1);
if ~ok || ~any(isnan(grid(:)))
    return
end
[grid, ok, modifiee] = ParcourirColonnes(grid, n, 1);
if ok && modifiee
    [grid, ok] = DirectValues(grid, n);
end
end

function [grille, ok, modifiee] = ParcourirColonnes(grille, n, colonne)
ok = true;
modifiee = false;
if colonne > n
    return
end
[grille, ok, modifiee] = ParcourirColonne(grille, n, 1, colonne);
if ok
    [grille, ok, suiteModifiee] = ParcourirColonnes(grille, n, colonne + 1);
    modifiee = modifiee || suiteModifiee;
end
end

function [grille, ok, modifiee] = ParcourirColonne(grille, n, ligne, colonne)
ok = true;
modifiee = false;
if ligne > n
    return
end
if isnan(grille(ligne, colonne))
    zeroPossible = CheckValidMove(grille, ligne, colonne, 0, n);
    unPossible = CheckValidMove(grille, ligne, colonne, 1, n);
    if ~zeroPossible && ~unPossible
        ok = false;
        return
    end
    if zeroPossible ~= unPossible
        grille(ligne, colonne) = 1 * unPossible;
        modifiee = true;
    end
end
[grille, ok, suiteModifiee] = ParcourirColonne(grille, n, ligne + 1, colonne);
modifiee = modifiee || suiteModifiee;
end
