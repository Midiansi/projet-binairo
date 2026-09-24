function figureBinairo = CreerFigureBinairo(grilleInitiale, grilleResolue, fichier, faisable)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Dessiner les indices en noir, les valeurs ajoutees en bleu et les informations du PDF.
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
    grilleResolue = grilleInitiale;
end
n = size(grilleInitiale, 1);
lignesNom = DecouperNom(nomSource);
hauteurEntete = max(0.9, 0.25 * (numel(lignesNom) + 1)) * n / 6;
figureBinairo = figure('Color', 'white', 'Name', 'Resultat du Binairo', ...
    'NumberTitle', 'off', 'Position', [100 100 700 820]);
axesBinairo = axes('Parent', figureBinairo, 'Position', [0.07 0.07 0.86 0.86]);
axis(axesBinairo, 'ij');
axis(axesBinairo, 'equal');
axis(axesBinairo, [-0.05 n + 0.05 -hauteurEntete n + 0.05]);
axis(axesBinairo, 'off');
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
texteDate = char(datetime('now'));
text(axesBinairo, n, -hauteurEntete + 0.12 * n / 6, texteDate, ...
    'Color', [0 0 0], 'FontSize', 8, 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top');
if ~faisable
    text(axesBinairo, n / 2, n / 2, '== Error ==', 'Color', [1 0 0], ...
        'FontWeight', 'bold', 'FontSize', 44, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end
drawnow;
end

function lignes = DecouperNom(nom)
% Couper les noms longs sur plusieurs lignes sans interpreter les caracteres du nom.
if numel(nom) <= 32
    lignes = {nom};
else
    lignes = [{nom(1:32)}; DecouperNom(nom(33:end))];
end
end

function DessinerChiffre(axesBinairo, x, y, grille, masque, chiffre, couleur, taille)
indices = masque & grille == chiffre;
if any(indices(:))
    text(axesBinairo, x(indices), y(indices), num2str(chiffre), ...
        'Color', couleur, 'FontWeight', 'bold', 'FontSize', taille, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end
end
