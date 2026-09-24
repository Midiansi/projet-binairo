function DisplayBinairo(Original, Solution, file, feasible)
% Projet Binairo - ME-213
% Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
% Enregistrer la figure en PDF dans le dossier courant, puis la fermer.
[cheminPdf, ~] = CheminPdfBinairo(file);
figureBinairo = CreerFigureBinairo(Original, Solution, file, feasible);
% Une erreur est transmise au lanceur ; LabVIEW doit verifier le succes avant de lire le PDF.
print(figureBinairo, cheminPdf, '-dpdf', '-painters');
close(figureBinairo);
fprintf('PDF enregistre : %s\n', cheminPdf);
end
