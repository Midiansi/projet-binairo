function ExecuterBinairo(B, fichierSource, resoudreAvecMatlab, afficherPdf)
% EXECUTERBINAIRO Appel possible depuis solve.m, genere par LabVIEW.
% Le dossier courant doit contenir les fonctions MATLAB et recevoir le PDF.
% Les deux options sont celles de l'interface du projet Binairo (P00, p. 26).
% uiopen pour le PDF : addendum du cours 2025, page PDF 15.
% Les erreurs natives sont transmises au lanceur, sans journal supplementaire.
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
