# Kit de tests pour la VM (hors rendu obligatoire)

Ajouté lors de l’audit du 16 novembre 2026. Ces fichiers servent à vérifier `OCR.exe` et les fonctions MATLAB sur la VM Windows. Ils ne font pas partie du programme évalué.

| Fichier | Rôle |
| --- | --- |
| `TestOCR.bat` | Lance `OCR.exe` sur 49 cas et compare le résultat à `attendu_ocr.txt` |
| `attendu_ocr.txt` | Résultat attendu de chaque cas : arguments ; code de retour ; première ligne de `CellValue.txt` |
| `cellules/` | 26 fichiers `Cell.bin` de test fabriqués pour l’audit (tailles limites, en-têtes faux, pixels manquants…) |
| `TestBinairo.m` | Contrôles automatiques de `SolveBinairo`, `GrilleBinairoValide`, `FormatGrilleValide`, `CheminPdfBinairo`, `DisplayBinairo` |

## Tester le C

1. Copiez dans `cellules` les huit fichiers Moodle : `Cell0.bin`, `Cell1.bin`, `CellEmpty.bin`, `Cell0_rect.bin`, `Cell1_rect.bin`, `CellEmpty_rect.bin`, `BadCell_1.bin`, `Bad_Cell0_morepx.bin`.
2. Copiez `OCR.exe` (compilation Release x64) dans ce dossier `Tests`.
3. Lancez `TestOCR.bat`. Réussite : `RESULTAT : tous les cas sont identiques a attendu_ocr.txt`.

`(vide)` signifie que `CellValue.txt` existe avec 0 octet (le programme le vide après une erreur) ; `(absent)` qu’il n’a pas été créé (nombre d’arguments incorrect).

Contenu des cellules fabriquées :

| Fichier | Contenu | Attendu à 88/90/90 |
| --- | --- | --- |
| `z50`, `o50`, `e50` | 50×50 : un 0, un 1, vide | `0`, `1`, `-1` à 100 % |
| `z1000` | 1000×1000, un 0 dans le coin bas droit | `0` à 100 %, en quelques secondes |
| `rect_o`, `rect_z` | 50×1000 avec un 1 ; 1000×50 avec un 0 | `1`, `0` |
| `z_tl`, `z_br`, `o_tr`, `o_bl` | 74×74, chiffre collé dans un coin | chiffre reconnu à 100 % |
| `asym` | hauteur 55, largeur 60, un seul pixel noir | `-1`, 99.969696 % |
| `h49`, `w49`, `h1001`, `w1001`, `neg`, `zero`, `bigendian` | dimension hors de [50..1000] | code 3 |
| `trunc1`, `hdronly`, `hdr3`, `empty` | pixels ou en-tête manquants | code 3 |
| `extra1` | un octet de trop | code 3 (choix documenté) |
| `val2` | un pixel de valeur 2 | code 3 |
| `black`, `checker` | tout noir ; damier | code 5 |

Les valeurs attendues ont été produites sur macOS (clang, `-O2`) avec les mêmes sources. `TestOCR.bat` n’a pas pu être exécuté hors de Windows : si le script lui-même pose problème, lancez les cas à la main et comparez avec `attendu_ocr.txt`.

## Tester MATLAB

Copiez `TestBinairo.m` dans le dossier qui contient les sept fonctions `.m`, placez-y le Current Folder de MATLAB et tapez `TestBinairo`. Réussite : uniquement des lignes `PASS` et `Nombre d'echecs : 0`. Ouvrez ensuite `Test_6x6.pdf`, `Test_4x4_Bad.pdf` et `Test_rect.v2.pdf` pour le contrôle visuel (indices noirs gras, ajouts bleus gras, nom en haut à gauche, date en haut à droite, `== Error ==` rouge au centre du second), puis supprimez-les.

Ce script n’a pas pu être exécuté pendant l’audit (pas de MATLAB sur la machine). La logique du solveur a été vérifiée séparément.
