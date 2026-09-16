function figureBinairo = CreerFigureBinairo(grilleInitiale, grilleResolue, fichier, faisable)
% CREERFIGUREBINAIRO Construire la figure utilisee par DisplayBinairo ; son appelant la ferme.
% Presentation : exercice MATLAB 1, p. 1 ; P00, p. 32 ; PDF exemples du cours.
% Le texte == Error == est conserve tel que demande par le professeur.
% Implementation avec assistance de Codex, 2026.
if ~FormatGrilleValide(grilleInitiale) || ~FormatGrilleValide(grilleResolue) || ...
        ~isequal(size(grilleInitiale), size(grilleResolue))
    error('Binairo:GrilleAffichage', 'Les grilles doivent etre carrees, de meme taille paire, de type double, avec 0, 1 ou NaN.');
end
if numel(faisable) ~= 1 || ~(isa(faisable, 'logical') || isa(faisable, 'double')) || ...
        ~(faisable == 0 || faisable == 1)
    error('Binairo:IndicateurFaisabilite', 'La faisabilite doit etre un scalaire logique ou valoir 0 ou 1.');
end
[~, nomSource] = CheminPdfBinairo(fichier);
indicesInitiaux = ~isnan(grilleInitiale);
if faisable && (~GrilleBinairoValide(grilleResolue) || any(grilleResolue(indicesInitiaux) ~= grilleInitiale(indicesInitiaux)))
    error('Binairo:SolutionAffichage', 'Une solution affichee comme faisable doit respecter les regles et les indices initiaux.');
end
if ~faisable
    grilleResolue = grilleInitiale; % En cas d'echec, afficher seulement les indices initiaux.
end
n = size(grilleInitiale, 1);
lignesNom = DecouperNom(nomSource);
hauteurEntete = max(0.9, 0.25 * (numel(lignesNom) + 1)) * n / 6;
figureBinairo = figure('Visible', 'off', 'Color', 'white', 'Name', 'Resultat du Binairo', ...
    'NumberTitle', 'off', 'Position', [100 100 700 820], ...
    'PaperUnits', 'inches', 'PaperSize', [8.5 11], ...
    'PaperPosition', [0.45 1.05 7.6 8.9], 'PaperPositionMode', 'manual');
axesBinairo = axes('Parent', figureBinairo, 'Position', [0.07 0.07 0.86 0.86], ...
    'XLim', [-0.05 n + 0.05], 'YLim', [-hauteurEntete n + 0.05], ...
    'YDir', 'reverse', 'DataAspectRatio', [1 1 1], 'Visible', 'off');
graduations = 0:n;
line(axesBinairo, [graduations; graduations], [zeros(size(graduations)); n * ones(size(graduations))], ...
    'Color', 'black', 'LineWidth', 0.75);
line(axesBinairo, [zeros(size(graduations)); n * ones(size(graduations))], [graduations; graduations], ...
    'Color', 'black', 'LineWidth', 0.75);
[x, y] = meshgrid((1:n) - 0.5, (1:n) - 0.5);
taillePolice = max(8, min(24, 132 / n));
DessinerChiffre(axesBinairo, x, y, grilleInitiale, indicesInitiaux, 0, [0 0 0], taillePolice);
DessinerChiffre(axesBinairo, x, y, grilleInitiale, indicesInitiaux, 1, [0 0 0], taillePolice);
casesResolues = isnan(grilleInitiale) & ~isnan(grilleResolue);
DessinerChiffre(axesBinairo, x, y, grilleResolue, casesResolues, 0, [0 0 1], taillePolice);
DessinerChiffre(axesBinairo, x, y, grilleResolue, casesResolues, 1, [0 0 1], taillePolice);
text(axesBinairo, 0, -hauteurEntete + 0.12 * n / 6, lignesNom, ...
    'Color', [0 0 1], 'FontWeight', 'bold', 'FontSize', 10, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
    'Interpreter', 'none');
% datetime fournit les composantes de la date ; num2str les met en texte.
dateCreation = datetime('now');
texteDate = num2str([dateCreation.Day dateCreation.Month dateCreation.Year ...
    dateCreation.Hour dateCreation.Minute floor(dateCreation.Second)], ...
    '%02d.%02d.%04d %02d:%02d:%02d');
text(axesBinairo, n, -hauteurEntete + 0.12 * n / 6, texteDate, ...
    'Color', [0 0 0], 'FontSize', 8, 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'Interpreter', 'none');
if ~faisable
    text(axesBinairo, n / 2, n / 2, '== Error ==', 'Color', [1 0 0], ...
        'FontWeight', 'bold', 'FontSize', 44, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'Interpreter', 'none');
end
drawnow;
end

function lignes = DecouperNom(nom)
% Cellules de caracteres (M3), indexation (M1) et recursion (ICC 13/14).
if numel(nom) <= 32
    lignes = {nom};
else
    lignes = [{nom(1:32)}; DecouperNom(nom(33:end))];
end
end

function DessinerChiffre(axesBinairo, x, y, grille, masque, chiffre, couleur, taille)
% text et num2str sont demandes dans l'exercice Binairo MATLAB 1.
indices = masque & grille == chiffre;
if any(indices(:))
    text(axesBinairo, x(indices), y(indices), num2str(chiffre), ...
        'Color', couleur, 'FontWeight', 'bold', 'FontSize', taille, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'Interpreter', 'none');
end
end
