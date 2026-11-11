# Images de test du cours ME-213

Ces six fichiers d’entrée sont fournis dans le dépôt pour que le groupe puisse tester directement sur la VM EPFL. Ils sont copiés **sans modification** de l’archive du cours `ME-213_1794318989.zip` transmise le 10 novembre 2026.

| Fichier | Usage dans la recette |
| --- | --- |
| `Binairo_6x6.png` | Exemple 6×6, V01 |
| `Binairo_6x6_rect.v2.png` | Exemple 6×6 à cellules rectangulaires, V26 ; version v2 ajoutée le 9 novembre |
| `Binairo_8x8.png` | Exemple 8×8, V02 |
| `Binairo_4x4_Bad.png` | Grille contradictoire, V03 |
| `Binaro_5x6_Bad.png` | Géométrie invalide, V04 ; conserver cette orthographe |
| `BadBinairo.png` | Fichier volontairement non PNG, V07 ; ne pas le réparer |

Dans l’archive reçue, `BadBinairo.png` contient du texte et n’est pas une image lisible. Le document du professeur décrit également le cas d’un document Word renommé `.png` : le comportement attendu est le même, une erreur de lecture visible. Ce fichier a été conservé tel quel.

## Utilisation sur la VM

Récupérez le dépôt complet avec **Code > Download ZIP**, puis extrayez-le dans votre dossier persistant. Les images sont dans `temp/Images` ; sélectionnez celle à traiter depuis la face avant LabVIEW. Si vous avez déjà commencé la recette, copiez uniquement ce dossier dans votre dossier de travail existant, sans remplacer vos VIs ni vos résultats. La recette reste dans `temp/Recette_LabVIEW_Binairo.pdf` (également disponible en HTML et Markdown).

## À exclure du rendu Moodle

**Ne mettez pas ce dossier ni les PNG sources dans l’archive finale.** L’addendum de soumission révision 3, page 3, demande : « Ne PAS mettre les séquences dans l’archive ».

Conservez en revanche les résultats générés dans les sous-dossiers `Preuves` prévus au §21.2 : `Cell.bin`, `CellValue.txt`, `solve.m` et le PDF de chaque séquence traitée. Pour les entrées refusées, conservez les diagnostics prévus par la recette, sans réutiliser d’anciennes sorties.

Le ZIP téléchargé depuis GitHub est une copie de travail, pas l’archive de remise : il contient ces images de test et ne contient pas encore les VIs construits, l’exécutable Windows testé ni tous les résultats. Assemblez le rendu après les essais, selon le chapitre 21.
