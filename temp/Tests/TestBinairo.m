% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Controles automatiques des fonctions MATLAB (outil de test, hors rendu).
% Utilisation : Current Folder = dossier contenant les sept fonctions .m du projet,
%               copier ce script dans ce dossier, puis taper TestBinairo.
% Chaque ligne affiche PASS ou FAIL ; la derniere ligne donne le nombre d'echecs.

nbEchecs = 0;

% Grilles du cours et solutions lues dans Binairo_6x6.pdf et Binairo_8x8.pdf (Moodle).
B6 = [NaN 0 NaN NaN NaN NaN; NaN NaN 0 NaN 0 NaN; NaN NaN NaN NaN 1 0; ...
      1 1 NaN NaN NaN NaN; NaN 0 NaN 0 NaN NaN; NaN NaN NaN NaN 0 NaN];
S6 = [1 0 0 1 1 0; 0 1 0 1 0 1; 1 0 1 0 1 0; 1 1 0 1 0 0; 0 0 1 0 1 1; 0 1 1 0 0 1];
B8 = [NaN 0 0 NaN NaN NaN NaN 0; NaN NaN NaN NaN NaN NaN NaN NaN; ...
      1 NaN 1 NaN 0 NaN NaN NaN; NaN NaN NaN NaN NaN NaN NaN 0; ...
      1 NaN NaN NaN 1 NaN NaN NaN; NaN NaN NaN NaN 1 NaN 1 NaN; ...
      NaN NaN 0 NaN NaN NaN NaN NaN; NaN 0 NaN NaN NaN NaN 0 0];
S8 = [1 0 0 1 1 0 1 0; 0 1 0 0 1 0 1 1; 1 0 1 0 0 1 0 1; 0 1 0 1 0 1 1 0; ...
      1 0 1 0 1 0 0 1; 0 1 1 0 1 0 1 0; 0 1 0 1 0 1 0 1; 1 0 1 1 0 1 0 0];
B4 = [NaN 0 0 NaN; NaN NaN NaN NaN; NaN 0 0 NaN; NaN NaN NaN NaN];

% --- Format et regles
nbEchecs = nbEchecs + Controle('Format : matrice vide refusee', ~FormatGrilleValide([]));
nbEchecs = nbEchecs + Controle('Format : 2x4 refusee', ~FormatGrilleValide(zeros(2, 4)));
nbEchecs = nbEchecs + Controle('Format : valeur 2 refusee', ~FormatGrilleValide([0 2; 1 0]));
nbEchecs = nbEchecs + Controle('Format : 3x3 refusee', ~FormatGrilleValide(NaN(3, 3)));
nbEchecs = nbEchecs + Controle('Regles : [0 1; 1 0] valide', GrilleBinairoValide([0 1; 1 0]));
nbEchecs = nbEchecs + Controle('Regles : lignes identiques refusees', ~GrilleBinairoValide([0 1; 0 1]));
nbEchecs = nbEchecs + Controle('Regles : trois 0 consecutifs refuses', ...
    ~GrilleBinairoValide([0 0 0 NaN; NaN NaN NaN NaN; NaN NaN NaN NaN; NaN NaN NaN NaN]));
nbEchecs = nbEchecs + Controle('Regles : trois 1 dans une ligne de 4 refuses', ...
    ~GrilleBinairoValide([1 1 NaN 1; NaN NaN NaN NaN; NaN NaN NaN NaN; NaN NaN NaN NaN]));

% --- Solveur
tic; [S, ok] = SolveBinairo(B6); duree6 = toc;
nbEchecs = nbEchecs + Controle('6x6 : resolu', ok);
nbEchecs = nbEchecs + Controle('6x6 : identique a la solution du cours', isequal(S, S6));
nbEchecs = nbEchecs + Controle('6x6 : indices initiaux conserves', isequal(S(~isnan(B6)), B6(~isnan(B6))));
tic; [S, ok] = SolveBinairo(B8); duree8 = toc;
nbEchecs = nbEchecs + Controle('8x8 : resolu', ok);
nbEchecs = nbEchecs + Controle('8x8 : identique a la solution du cours', isequal(S, S8));
nbEchecs = nbEchecs + Controle('8x8 : grille complete et valide', GrilleBinairoValide(S) && ~any(isnan(S(:))));
[S, ok] = SolveBinairo(B4);
nbEchecs = nbEchecs + Controle('4x4_Bad : sans solution', ~ok);
[S, ok] = SolveBinairo([0 NaN; NaN 0]);
nbEchecs = nbEchecs + Controle('2x2 : resolu en [0 1; 1 0]', ok && isequal(S, [0 1; 1 0]));
[S, ok] = SolveBinairo([0 0 0 NaN; NaN NaN NaN NaN; NaN NaN NaN NaN; NaN NaN NaN NaN]);
nbEchecs = nbEchecs + Controle('Grille initiale contradictoire : ok = false', ~ok);
[S, ok] = SolveBinairo(NaN(8, 8));
nbEchecs = nbEchecs + Controle('8x8 vide : une solution valide est trouvee', ...
    ok && GrilleBinairoValide(S) && ~any(isnan(S(:))));
[S, ok] = SolveBinairo(zeros(3, 3));
nbEchecs = nbEchecs + Controle('3x3 : refusee sans erreur MATLAB', ~ok);
fprintf('Durees de resolution : 6x6 %.3f s, 8x8 %.3f s\n', duree6, duree8);

% --- Nom du PDF
[pdf, nom] = CheminPdfBinairo('C:\Dossier test\Binairo_6x6.png');
nbEchecs = nbEchecs + Controle('Nom PDF : chemin Windows', isequal(pdf, 'Binairo_6x6.pdf') && isequal(nom, 'Binairo_6x6.png'));
nbEchecs = nbEchecs + Controle('Nom PDF : point dans le nom', isequal(CheminPdfBinairo('Binairo_6x6_rect.v2.png'), 'Binairo_6x6_rect.v2.pdf'));

% --- PDF (a ouvrir ensuite pour le controle visuel)
[S, ok] = SolveBinairo(B6);
DisplayBinairo(B6, S, 'Test_6x6.png', ok);
nbEchecs = nbEchecs + Controle('PDF solution cree : Test_6x6.pdf', exist('Test_6x6.pdf', 'file') == 2);
[S, ok] = SolveBinairo(B4);
DisplayBinairo(B4, S, 'Test_4x4_Bad.png', ok);
nbEchecs = nbEchecs + Controle('PDF == Error == cree : Test_4x4_Bad.pdf', exist('Test_4x4_Bad.pdf', 'file') == 2);
DisplayBinairo(B6, B6, 'Test_rect.v2.png', GrilleBinairoValide(B6));
nbEchecs = nbEchecs + Controle('PDF sans resolution cree : Test_rect.v2.pdf', exist('Test_rect.v2.pdf', 'file') == 2);

fprintf('\nNombre d''echecs : %d\n', nbEchecs);
fprintf('Controle visuel restant : ouvrir Test_6x6.pdf, Test_4x4_Bad.pdf et Test_rect.v2.pdf,\n');
fprintf('puis supprimer ces trois PDF de test.\n');

function echec = Controle(nom, condition)
% Afficher PASS ou FAIL et renvoyer 1 en cas d'echec.
if condition
    fprintf('PASS  %s\n', nom);
    echec = 0;
else
    fprintf('FAIL  %s\n', nom);
    echec = 1;
end
end
