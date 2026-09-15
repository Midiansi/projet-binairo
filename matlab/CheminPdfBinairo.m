function [cheminPdf, nomSource] = CheminPdfBinairo(fichier)
% CHEMINPDFBINAIRO Construire le chemin du PDF dans le dossier des fonctions MATLAB.
% Le chemin PNG sert a nommer le resultat ; MATLAB ne traite pas cette image.
% Implementation avec assistance de Codex, 2026.
if isstring(fichier) && isscalar(fichier)
    fichier = char(fichier);
end
if ~ischar(fichier) || size(fichier, 1) ~= 1 || isempty(fichier) || ...
        any(fichier == char(0) | fichier == char(10) | fichier == char(13))
    error('Binairo:FichierSource', 'Le chemin du fichier PNG doit etre unique et non vide.');
end
[~, nom, extension] = fileparts(fichier);
if isempty(nom) || ~strcmpi(extension, '.png')
    error('Binairo:FichierSource', 'Le fichier source doit avoir un nom et une extension .png.');
end
nomSource = [nom extension];
dossierProgramme = fileparts(mfilename('fullpath'));
cheminPdf = fullfile(dossierProgramme, [nom '.pdf']);
end
