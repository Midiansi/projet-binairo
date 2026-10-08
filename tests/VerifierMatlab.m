% Verification native du projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Copier ce script dans le dossier contenant les sept fonctions du projet.
% Ce script est un test : il ne remplace pas solve.m genere par LabVIEW.
% Il utilise if/error, matrices et fonctions du cours, sans boucle explicite.

if ~GrilleBinairoValide([0 1; 1 0])
    error('Une grille complete valide a ete refusee.');
end
if GrilleBinairoValide([0 1; 0 1]) || GrilleBinairoValide(zeros(3, 3)) || ...
        FormatGrilleValide(zeros(2, 4)) || FormatGrilleValide([]) || ...
        FormatGrilleValide([0 2; 1 0])
    error('Une grille invalide a ete acceptee.');
end
% Trois valeurs egales, puis lignes completes identiques.
if GrilleBinairoValide([0 0 0 NaN; NaN NaN NaN NaN; NaN NaN NaN NaN; NaN NaN NaN NaN]) || ...
        GrilleBinairoValide([0 1 0 1; 0 1 0 1; NaN NaN NaN NaN; NaN NaN NaN NaN])
    error('Une regle du Binairo a ete ignoree.');
end
B = [0 NaN; NaN 0];
[S, ok] = SolveBinairo(B);
if ~ok || ~isequal(S, [0 1; 1 0])
    error('Echec du test de resolution 2 par 2.');
end
% Affichage seul, avant le test combine des fonctions.
DisplayBinairo([0 NaN; NaN 0], [0 1; 1 0], 'Controle_affichage.png', true);

B = [NaN 0 NaN NaN NaN NaN;
     NaN NaN 0 NaN 0 NaN;
     NaN NaN NaN NaN 1 0;
     1 1 NaN NaN NaN NaN;
     NaN 0 NaN 0 NaN NaN;
     NaN NaN NaN NaN 0 NaN];
[S, ok] = SolveBinairo(B);
indices = ~isnan(B);
if ~ok || any(isnan(S(:))) || ~GrilleBinairoValide(S) || any(S(indices) ~= B(indices))
    error('Echec du 6 par 6 ou modification des indices.');
end
DisplayBinairo(B, S, 'Binairo_6x6.png', ok);

B = [NaN 0 0 NaN NaN NaN NaN 0;
     NaN NaN NaN NaN NaN NaN NaN NaN;
     1 NaN 1 NaN 0 NaN NaN NaN;
     NaN NaN NaN NaN NaN NaN NaN 0;
     1 NaN NaN NaN 1 NaN NaN NaN;
     NaN NaN NaN NaN 1 NaN 1 NaN;
     NaN NaN 0 NaN NaN NaN NaN NaN;
     NaN 0 NaN NaN NaN NaN 0 0];
[S, ok] = SolveBinairo(B);
indices = ~isnan(B);
if ~ok || any(isnan(S(:))) || ~GrilleBinairoValide(S) || any(S(indices) ~= B(indices))
    error('Echec du 8 par 8 ou modification des indices.');
end
DisplayBinairo(B, S, 'Binairo_8x8.png', ok);

B = [NaN 0 0 NaN; NaN NaN NaN NaN; NaN 0 0 NaN; NaN NaN NaN NaN];
[S, ok] = SolveBinairo(B);
if ok
    error('La grille 4 par 4 contradictoire a ete declaree resolue.');
end
DisplayBinairo(B, S, 'Binairo_4x4_Bad.png', ok);

B = [0 NaN; NaN 0];
DisplayBinairo(B, B, 'L''exemple_test.png', GrilleBinairoValide(B));
fprintf('Tests MATLAB termines. Inspecter les cinq PDF : couleurs, indices, nom, date et message Error.\n');
% Les quatre options, le vrai solve.m, uiopen et les erreurs de lancement
% doivent encore etre testes depuis les VIs suivant la recette.
