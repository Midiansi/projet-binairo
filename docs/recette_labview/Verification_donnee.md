# Vérification — addendum Binairo du 7 octobre 2026

Mise à jour du 8 octobre 2026. L’addendum `P0.PPI_Projet_soumission.26.1.pdf` prime pour les noms, erreurs et constantes ; `P00.PPI_Projet.2026.2.pdf` et les exercices compatibles donnent les algorithmes. Pages physiques à partir de 1. Ce document remplace le contrôle du 24 septembre, devenu partiellement obsolète.

## Corrections apportées

| Point | Modification | Référence |
|---|---|---|
| Dimensions C et LabVIEW |50..1000 inclus, exemples géométriques et binaires corrigés | addendum p. 10 |
| Seuils | entiers 1..99 ; parseur C sans fractions ; validation DBL/intégralité puis commande I32 | addendum p. 10–11 |
| Défauts |88/90/90 partout, avec sauvegarde des défauts des contrôles | addendum p. 11–12 et 15 |
| Crop et vide | conserver au plus 2 pixels réels du trait de chaque côté ; limiter la bordure extérieure ; ne pas modifier le test OCR demandé | donnée p. 10 ; exercice LV1 p. 16 |
| Génération de solve.m | doubler la barre inverse du format N6 pour conserver le backslash-n MATLAB | LV2 chaînes/formats ; documentation NI Format Into String |
| Parser OCR | Scan From String puis reformatage/comparaison stricte, sans expressions régulières | LV2 p. 47–48 |
| Contrôles de chemins | boucle de caractères + comparaisons, sans expressions régulières ; lancement MATLAB direct sans shell | LV1/LV2 ; exercice de lancement |
| Erreur d’existence de fichier | propager error out de Check if File or Folder Exists | LV2 erreurs ; documentation NI |
| Documentation et projets | solution/projet Visual Studio, documentation courte et carte des techniques | addendum p. 4 et 8 |
| Remise | sauvegarde des résultats par séquence, transcripts, archive nominative et contrôle après téléchargement | addendum p. 3–4 et 8 |

Les scores restent décimaux ; les seuils sont des entiers. Le nombre de cellules de la grille doit être pair et égal sur les deux axes ; une cellule bitmap peut être rectangulaire. Les cinq sources/header C et les sept fonctions MATLAB conservent leurs interfaces. Le header original de police reste inchangé.

## Techniques conformes au programme

[Conformite_programme.md](../Conformite_programme.md) donne les références ME-213/CS-119a pour les techniques et fonctions. Les structures, allocation, bitwise, fichiers, nettoyage goto, matrice/masques et récursion proviennent de ces cours. Les trois expressions régulières de la recette ont été remplacées par chaînes/boucles/comparaisons du cours. Aucune bibliothèque d’OCR, de résolution ou de traitement d’image n’est ajoutée.

## Mesures réellement réalisées

| Vérification | Résultat |
|---|---|
| Build C11 Apple Clang 21/macOS 27.0.1 arm64 | passe avec Wall/Wextra/Wpedantic/Werror/Wvla |
|126 appels du vrai C |0 désaccord ; limites 49/50/1000/1001 sur chaque axe, seuils invalides dans les 3 positions, fichiers et erreurs |
|16 appels directs de ConvertirSeuil | domaine/syntaxe attendus ; sortie 0 à l’échec |
|8 cas de choix de chiffre | égalité du score au seuil, marges différentes, égalité des marges et absence de candidat corrects |
|2048 bits de la police | corrects ; fichier fourni inchangé |
|6 appels avec ASan/UBSan | pas de diagnostic ; ce n’est pas une preuve exhaustive d’absence de faute mémoire |
|116 cellules ×4 conversions RGB |464 sorties correctes à 88/90/90 ; aucun des 29 indices perdu |
|Géométrie du 5×6 | refus dans les 4 conversions d’essai |
|Vérification du texte généré | quatre combinaisons des options et nom avec apostrophe ; messages MATLAB sur une seule ligne source |
|Ancienne revue des fonctions MATLAB, restées inchangées | modèles indépendants : 65536 grilles complètes 4×4 et 381 partielles, sans désaccord ; pas une exécution de .m |

Pour le replay image, TRUE si la moyenne RGB est inférieure à 100,128,160 ou 200 ; l’intervalle du trait est mesuré sur chaque bitmap. Ce protocole vérifie le contrat rectangle/C ; la conversion native Picture to Pixmap reste à essayer sur la VM.

À 128, les cases vides ont environ 89,41–89,62 % de blanc et les chiffres 82,74–85,53 %. La première cellule 6×6 est [4,4,80,76), largeur 76, hauteur 72, soit 5480 octets. La première 8×8 est [6,11,82,83), largeur 76, hauteur 72. L’exemple binaire indépendant 55×60 possède 3308 octets ; son pixel noir(2,9) est à l’offset 137. Les fichiers74×74 du professeur restent des exemples séparés.

## Ce qui reste à prouver nativement

- Build Visual Studio/GCC et exécution OCR.exe sur la VM ; la configuration projet est fournie mais n’a pas été exécutée sous MSVC ici.
- Construction des VIs ; conversion NI et câblage réel ; erreurs système et valeurs par défaut.
- Tests MATLAB du script `tests/VerifierMatlab.m`, rendu des cinq PDF, puis intégration via le solve.m réellement généré.
- Quatre options résolution/ouverture par System Exec, avec attente et remontée d’erreurs réelles.
- Essais V01–V25, fichiers par séquence et archive retéléchargée/testée ailleurs.

Ni capture, ni score de test natif, ni transcript intégral ne sont inventés. La recette est corrigée et accompagnée de checkpoints, mais ne devient une construction vérifiée qu’après ces essais.

## Migration depuis la recette du 1 octobre

1. Remplacer les fichiers C par cette révision et recompiler. Conserver les cinq sources/header et les deux fichiers Visual Studio ensemble.
2. SeuilsOCR.ctl garde ses trois DBL ; changer le défaut à 88/90/90. Refaire CommandeOCR suivant 10 : plage 1..99, comparaison avec conversion I32, puis format `%d`.
3. Refaire G4.1/G4.3 : huit coordonnées de traits, quatre épaisseurs et quatre Less?/Select. Remplacer les checkpoints G4.4/G6.1 ; ne plus attendre une cellule 72×68 sans bord.
4. EcrireCellule : bornes 50..1000 ; checkpoint 55×60. Son connecteur et son format binaire ne changent pas.
5. Construire TexteCheminValide.vi(6.1), refaire les validations des chemins 15.2/17.2 et remplacer la commande MATLAB par l’appel direct indiqué. Ne pas garder cmd /c autour du nouveau format.
6. Refaire AnalyserResultatOCR suivant 11 avec Scan/Format/comparaison ; le connecteur reste inchangé. SupprimerResultat doit propager N1.error out.
7. Remplacer **seulement le bloc de format N6** par le bloc 13, en Normal Display, avec deux barres inverses devant n dans les fprintf. Les scripts d’exemple générés en ont une seule.
8. Remettre les defaults, exécuter les checkpoints puis V01–V25. Les matrices 6×6,8×8 et 4×4_Bad figurent au chapitre 18. Suivre 21 pour la remise.

Le choix de marge p. 18, la stricte inégalité du vide p. 10, le choix 0 à marge égale et les politiques de warning sont décrits dans [Documentation_projet.md](../Documentation_projet.md). La liste d’erreurs n’est plus considérée comme « à venir » : elle est publiée dans l’addendum du 7 octobre.
