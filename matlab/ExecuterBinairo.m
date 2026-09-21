function ExecuterBinairo(B, fichierSource, resoudreAvecMatlab, afficherPdf)
if ~isa(resoudreAvecMatlab, 'logical') || numel(resoudreAvecMatlab) ~= 1 || ...
        ~isa(afficherPdf, 'logical') || numel(afficherPdf) ~= 1
    error('Les options de resolution et affichage doivent etre des scalaires logiques.');
end
if ~FormatGrilleValide(B)
    error('B doit etre une matrice double carree de taille paire avec 0, 1 ou NaN.');
end
[cheminPdf, ~] = CheminPdfBinairo(fichierSource);
printGrid(B);
if resoudreAvecMatlab
    [solution, faisable] = SolveBinairo(B);
else
    solution = B;
    faisable = GrilleBinairoValide(B);
end
DisplayBinairo(B, solution, fichierSource, faisable);
if afficherPdf
    uiopen(cheminPdf, 1);
end
if faisable
    fprintf('Binairo traite.\n');
else
    fprintf('Grille contradictoire ou sans solution.\n');
end
end
