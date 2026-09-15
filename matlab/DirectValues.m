function [grid, ok] = DirectValues(grid, n)
% DIRECTVALUES Appliquer les deductions certaines jusqu'a stabilisation.
% Ordre de SolveBinairoHeader.m : visiter chaque case vide, affecter sa seule
% valeur possible, passer a la suivante, puis recommencer si la grille change.
% Implementation avec assistance de Codex, 2026.
ok = isnumeric(n) && isreal(n) && isscalar(n) && ...
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
% Parcourir la moitie gauche avant la droite, en transmettant la grille modifiee.
% L'ordre reste celui des indices ; la profondeur du parcours est logarithmique.
ok = true;
modifiee = false;
if debut > fin
    return
end
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
if xor(zeroPossible, unPossible)
    grille(r, c) = double(unPossible);
    modifiee = true;
end
end
