function [cheminPdf, nomSource] = CheminPdfBinairo(fichier)
% Projet Binairo - ME-213
% Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphael Raphaël Pical
% Former le nom du PDF dans le dossier courant a partir du nom du PNG.
if ~isa(fichier, 'char') || size(fichier, 1) ~= 1 || isempty(fichier) || ...
        any(fichier == 0 | fichier == 10 | fichier == 13)
    error('Le fichier PNG doit etre une ligne de caracteres non vide.');
end
separateurs = find(fichier == '/' | fichier == '\');
if isempty(separateurs)
    debut = 1;
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
