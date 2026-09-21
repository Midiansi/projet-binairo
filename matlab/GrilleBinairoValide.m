function ok = GrilleBinairoValide(grille)
% GRILLEBINAIROVALIDE Verifier toutes les lignes et toutes les colonnes.
% Appels des fonctions du professeur ; parcours recursif sans boucle explicite.
ok = FormatGrilleValide(grille);
if ok
    n = size(grille, 1);
    ok = VerifierIntervalle(grille, n, 1, n);
end
end

function ok = VerifierIntervalle(grille, n, debut, fin)
% Subdivision recursive : principe presente en C8 et dans la demo Simpson.
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
