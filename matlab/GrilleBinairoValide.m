function ok = GrilleBinairoValide(grille)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphael Raphaël Pical
% Verifier les regles sur toutes les lignes et toutes les colonnes.
ok = FormatGrilleValide(grille);
if ok
    n = size(grille, 1);
    ok = VerifierIntervalle(grille, n, 1, n);
end
end

function ok = VerifierIntervalle(grille, n, debut, fin)
% Diviser l'intervalle limite la profondeur du parcours recursif.
if debut == fin
    ok = CheckVectorOk(grille(debut, :), n) && ...
        CheckVectorOk(grille(:, debut), n) && ...
        CheckVectorUniqueOk(grille, debut, debut, n);
else
    milieu = floor((debut + fin) / 2);
    ok = VerifierIntervalle(grille, n, debut, milieu) && ...
        VerifierIntervalle(grille, n, milieu + 1, fin);
end
end
