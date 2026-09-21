function [cheminPdf, nomSource] = CheminPdfBinairo(fichier)
% CHEMINPDFBINAIRO Nommer le PDF a partir du fichier PNG fourni par LabVIEW.
% Le script solve.m est lance dans le dossier contenant les fonctions MATLAB.
% Le PDF est ecrit dans ce dossier courant. Aucun chemin personnel n'est fixe.
% Techniques : matrices de caracteres, find et indexation (M1/M2).
if ~isa(fichier, 'char') || size(fichier, 1) ~= 1 || isempty(fichier) || ...
        any(fichier == 0 | fichier == 10 | fichier == 13)
    error('Le fichier PNG doit etre une ligne de caracteres non vide.');
end
separateurs = find(fichier == '/' | fichier == '\');
if isempty(separateurs)
    debut = 1;
    % Accepter egalement un chemin relatif a un lecteur, par exemple C:grille.png.
    if numel(fichier) >= 2 && fichier(2) == ':'
        debut = 3;
    end
else
    debut = separateurs(end) + 1;
end
nomSource = fichier(debut:end);
if numel(nomSource) <= 4
    error('Le fichier source doit avoir un nom suivi de .png.');
end
extension = nomSource(end-3:end);
if any(~(extension == '.png' | extension == '.PNG'))
    error('Le fichier source doit avoir une extension .png.');
end
cheminPdf = [nomSource(1:end-4) '.pdf'];
end
