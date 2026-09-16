function DisplayBinairo(Original, Solution, file, feasible)
% DISPLAYBINAIRO Ecrire le PDF demande dans le dossier courant de solve.m.
% Signature exacte de l'exercice MATLAB 1, page 1.
% print et ses options : fonction indiquee page 2, qui renvoie a help/doc.
% Une erreur MATLAB est transmise au lanceur LabVIEW ; aucun resultat ne doit
% etre utilise par LabVIEW si le lancement ou le script signale une erreur.
% Implementation avec assistance de Codex, 2026.
[cheminPdf, ~] = CheminPdfBinairo(file);
figureBinairo = CreerFigureBinairo(Original, Solution, file, feasible);
print(figureBinairo, cheminPdf, '-dpdf', '-painters');
close(figureBinairo);
fprintf('PDF enregistre : %s\n', cheminPdf);
end
