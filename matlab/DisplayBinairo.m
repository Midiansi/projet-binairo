function DisplayBinairo(Original, Solution, file, feasible)
[cheminPdf, ~] = CheminPdfBinairo(file);
figureBinairo = CreerFigureBinairo(Original, Solution, file, feasible);
print(figureBinairo, cheminPdf, '-dpdf', '-painters');
close(figureBinairo);
fprintf('PDF enregistre : %s\n', cheminPdf);
end
