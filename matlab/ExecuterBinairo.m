function ExecuterBinairo(B, fichierSource, resoudreAvecMatlab, afficherPdf)
% EXECUTERBINAIRO Point d'entree utilisable dans solve.m, genere par LabVIEW.
% Aucun traitement d'image ici. Un seul calcul a la fois dans ce dossier.
% Les fichiers d'etat et le journal sont produits seulement lors de l'execution.
% Implementation avec assistance de Codex, 2026.
dossierProgramme = fileparts(mfilename('fullpath'));
cheminEtat = fullfile(dossierProgramme, 'EtatMatlab.txt');
cheminErreur = fullfile(dossierProgramme, 'ErreurMatlab.txt');
cheminJournal = fullfile(dossierProgramme, 'ExecutionMatlab.log');
diary('off');
try
    SupprimerAncienFichier(cheminEtat);
    SupprimerAncienFichier(cheminErreur);
    SupprimerAncienFichier(cheminJournal);
    diary(cheminJournal);
    fermerJournal = onCleanup(@() diary('off')); %#ok<NASGU>
    fprintf('Debut du calcul Binairo avec MATLAB : %s\n', char(datetime('now')));
    fprintf('MATLAB %s | %s\n', version, computer);
    [cheminPdf, nomSource] = CheminPdfBinairo(fichierSource);
    SupprimerAncienFichier(cheminPdf);
    fprintf('Source: %s\n', nomSource);
    if ~islogical(resoudreAvecMatlab) || ~isscalar(resoudreAvecMatlab) || ...
            ~islogical(afficherPdf) || ~isscalar(afficherPdf)
        error('Binairo:Options', 'Les options de resolution et d''affichage doivent etre des scalaires logiques.');
    end
    if ~FormatGrilleValide(B)
        error('Binairo:GrilleEntree', 'B doit etre une matrice reelle carree de taille paire, de type double, avec 0, 1 ou NaN, et n >= 2.');
    end
    fprintf('Grille : %d x %d ; resolution=%d ; affichage PDF=%d\n', size(B, 1), size(B, 2), resoudreAvecMatlab, afficherPdf);
    printGrid(B);
    if resoudreAvecMatlab
        [solution, faisable] = SolveBinairo(B);
    else
        solution = B;
        faisable = GrilleBinairoValide(B);
        fprintf('Resolution desactivee : affichage des indices initiaux uniquement.\n');
    end
    DisplayBinairo(B, solution, fichierSource, faisable);
    if afficherPdf
        etatOuverture = web(cheminPdf, '-browser');
        if etatOuverture ~= 0
            error('Binairo:LecteurPDF', 'PDF enregistre, mais ouverture impossible dans le lecteur du systeme (etat %d).', etatOuverture);
        end
        fprintf('Ouverture du PDF demandee au lecteur du systeme.\n');
    end
    if faisable
        resultat = 'OK';
    else
        resultat = 'INSOLUBLE';
    end
    EcrireTexteBinairo(cheminEtat, [resultat char(10)]);
    fprintf('ETAT BINAIRO : %s\n', resultat);
catch exception
    rapport = getReport(exception, 'extended', 'hyperlinks', 'off');
    fprintf(2, '%s\n', rapport);
    try
        EcrireTexteBinairo(cheminErreur, [rapport char(10)]);
        EcrireTexteBinairo(cheminEtat, ['ERREUR' char(10)]);
    catch erreurRapport
        fprintf(2, 'Impossible d''ecrire les fichiers d''erreur et d''etat : %s\n', erreurRapport.message);
    end
    rethrow(exception);
end
end

function SupprimerAncienFichier(fichier)
if exist(fichier, 'file') == 2
    delete(fichier);
end
end
