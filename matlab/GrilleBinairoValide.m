function ok = GrilleBinairoValide(grille)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Verifier les regles sur toutes les lignes et toutes les colonnes.
ok = FormatGrilleValide(grille);
if ~ok
    return
end
n = size(grille, 1);
casesZero = 1 * (grille == 0);
casesUn = 1 * (grille == 1);
comptesOk = ~any(sum(casesZero, 1) > n/2) && ~any(sum(casesZero, 2) > n/2) && ...
    ~any(sum(casesUn, 1) > n/2) && ~any(sum(casesUn, 2) > n/2);
troisEnLigne = grille(:, 1:end-2) == grille(:, 2:end-1) & ...
    grille(:, 2:end-1) == grille(:, 3:end);
troisEnColonne = grille(1:end-2, :) == grille(2:end-1, :) & ...
    grille(2:end-1, :) == grille(3:end, :);
% Chaque produit compte les positions egales entre deux lignes ou deux colonnes.
egalesLignes = casesZero * casesZero.' + casesUn * casesUn.';
egalesColonnes = casesZero.' * casesZero + casesUn.' * casesUn;
% Une ligne complete est egale a elle-meme ; deux correspondances signalent un doublon.
uniques = ~any(sum(egalesLignes == n, 2) > 1) && ...
    ~any(sum(egalesColonnes == n, 2) > 1);
ok = comptesOk && ~any(troisEnLigne(:)) && ~any(troisEnColonne(:)) && uniques;
end
