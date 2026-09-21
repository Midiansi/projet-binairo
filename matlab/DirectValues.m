function [grid, ok] = DirectValues(grid, n)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphael Raphaël Pical
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
if ~ok
    return
end
indicesVides = find(isnan(grid));
[grid, ok, modifiee] = ParcourirCases(grid, n, indicesVides, 1, numel(indicesVides));
if ok && modifiee
    [grid, ok] = DirectValues(grid, n);
end
end

function [grille, ok, modifiee] = ParcourirCases(grille, n, indicesVides, debut, fin)
ok = true;
modifiee = false;
if debut > fin
    return
end
% Parcourir les deux moities dans l'ordre, en transmettant les deductions deja faites.
if debut < fin
    milieu = floor((debut + fin) / 2);
    [grille, ok, gaucheModifiee] = ParcourirCases(grille, n, indicesVides, debut, milieu);
    modifiee = gaucheModifiee;
    if ~ok
        return
    end
    [grille, ok, droiteModifiee] = ParcourirCases(grille, n, indicesVides, milieu + 1, fin);
    modifiee = modifiee || droiteModifiee;
    return
end
[r, c] = ind2sub([n n], indicesVides(debut));
zeroPossible = CheckValidMove(grille, r, c, 0, n);
unPossible = CheckValidMove(grille, r, c, 1, n);
if ~zeroPossible && ~unPossible
    ok = false;
    return
end
if zeroPossible ~= unPossible
    grille(r, c) = 1 * unPossible;
    modifiee = true;
end
end
