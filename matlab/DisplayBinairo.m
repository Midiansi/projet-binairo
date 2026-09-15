function DisplayBinairo(Original, Solution, file, feasible)
% DISPLAYBINAIRO Enregistrer le PDF dans le dossier des fonctions MATLAB.
% Signature exacte de l'exercice MATLAB 1, page 1.
% Implementation avec assistance de Codex, 2026.
[cheminPdf, ~] = CheminPdfBinairo(file);
if exist(cheminPdf, 'file') == 2
    delete(cheminPdf);
end
figureBinairo = CreerFigureBinairo(Original, Solution, file, feasible);
fermerFigure = onCleanup(@() close(figureBinairo)); %#ok<NASGU>
temporaire = [tempname(fileparts(cheminPdf)) '.pdf'];
supprimerTemporaire = onCleanup(@() SupprimerTemporaire(temporaire)); %#ok<NASGU>
print(figureBinairo, temporaire, '-dpdf', '-painters');
info = dir(temporaire);
if isempty(info) || info.bytes == 0
    error('Binairo:EcriturePDF', 'MATLAB ne produit aucun PDF non vide.');
end
[ok, message] = movefile(temporaire, cheminPdf, 'f');
if ~ok
    error('Binairo:EcriturePDF', 'Impossible de sauvegarder le PDF : %s', message);
end
fprintf('PDF enregistre : %s\n', cheminPdf);
end

function SupprimerTemporaire(fichier)
if exist(fichier, 'file') == 2
    delete(fichier);
end
end
