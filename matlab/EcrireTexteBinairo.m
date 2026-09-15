function EcrireTexteBinairo(fichier, texte)
% ECRIRETEXTEBINAIRO Ecrire un texte en UTF-8, puis remplacer le fichier de destination.
% Implementation avec assistance de Codex, 2026.
temporaire = [tempname(fileparts(fichier)) '.txt'];
fichierOuvert = -1;
try
    [fichierOuvert, message] = fopen(temporaire, 'wb');
    if fichierOuvert < 0
        error('Binairo:EcritureTexte', 'Impossible de creer le fichier texte : %s', message);
    end
    octets = unicode2native(char(texte), 'UTF-8');
    nombreEcrits = fwrite(fichierOuvert, octets, 'uint8');
    etatFermeture = fclose(fichierOuvert);
    fichierOuvert = -1;
    if nombreEcrits ~= numel(octets) || etatFermeture ~= 0
        error('Binairo:EcritureTexte', 'Ecriture incomplete ou echec de fermeture du fichier texte.');
    end
    [ok, message] = movefile(temporaire, fichier, 'f');
    if ~ok
        error('Binairo:EcritureTexte', 'Impossible de remplacer le fichier texte : %s', message);
    end
catch exception
    if fichierOuvert >= 0
        fclose(fichierOuvert);
    end
    if exist(temporaire, 'file') == 2
        delete(temporaire);
    end
    rethrow(exception);
end
end
