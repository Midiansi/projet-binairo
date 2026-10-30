# Binairo – changements LabVIEW

30 octobre 2026 · Romeo Mugnier de Almeida

Le prof a corrigé le format de Cell.bin et de CellValue.txt sur Ed (29–31 oct.) et le code C a été mis à jour : côté LabVIEW, il faut modifier deux VIs (EcrireCellule, AnalyserResultatOCR) et recompiler OCR.exe. Le reste de la recette ne change pas.

## En bref

Deux formats de fichier ont changé. Tout le reste de la chaîne LabVIEW est identique.

```text
Cell.bin (écrit par EcrireCellule.vi)
  avant : [largeur u32][hauteur u32][pixels ligne par ligne]
  après : [hauteur u32][largeur u32][pixels ligne par ligne]

CellValue.txt pour une case vide (lu par AnalyserResultatOCR.vi)
  avant : d:'-2', 0.000000%
  après : d:'-1', 88.166542%     <- pourcentage = ratio de pixels blancs
```

Les sources C et la recette mises à jour sont sur la branche main du dépôt projet-binairo (PR #3, fusionnée le 30.10), issues de la branche `correction-ordre-hauteur-vide`. Dans la recette, chaque passage modifié porte la mention *(modifié le 30.10)*.

## Pourquoi

Le prof a précisé la donnée sur Ed, surtout entre le 10 et le 31 octobre ; le C suit maintenant ces corrections, et deux VIs doivent suivre le C.

| Source | Ce qui change | Effet côté LabVIEW |
| --- | --- | --- |
| Ed #29 et message Semaine 7 (#30) | Cell.bin commence par la **hauteur**, puis la largeur | EcrireCellule.vi : inverser l'en-tête |
| Ed #16 et note Moodle du 13.10 | Une case vide s'écrit `d:'-1', <ratio de blancs>%` au lieu de `d:'-2', 0.000000%` | AnalyserResultatOCR.vi : case `-2` devient `-1` |
| Ed #28 et Semaine 7 (#30) | Le C teste 0 et 1 d'abord, puis seulement la case vide | Aucun |
| Ed #7 | 0 et 1 admissibles à égalité : le C s'arrête avec le code 7 | Aucun : un code non nul donne déjà l'erreur 7006 |
| Robustesse | Après une erreur, le C vide CellValue.txt | Aucun : LireCase le supprime déjà avant chaque appel |

Le prof teste aussi le C seul avec ses propres Cell.bin rectangulaires au nouveau format : garder l'ancien ordre des deux côtés n'est donc pas une option.

## À faire selon votre avancement

À environ 30 % de la recette, seul OCR.exe (§1.1) est probablement à reprendre ; §9 et §11 se suivent simplement dans la nouvelle version.

| Partie de la recette | Si elle est déjà faite | Si elle n'est pas encore faite |
| --- | --- | --- |
| §1.1 Compiler le C | Recompiler OCR.exe avec les nouvelles sources et refaire les tests (changement 3) | Suivre la recette mise à jour |
| §2 à §8 et annexe G (gestes, types, ErreurSi, LireTexte/EcrireTexte, SupprimerResultat, LireImage, géométrie) | Rien à refaire | Suivre la recette |
| §9 EcrireCellule.vi | Inverser deux fils et refaire le checkpoint 9.3 (changement 1) | Suivre la recette mise à jour |
| §10 CommandeOCR.vi | Rien à refaire | Suivre la recette |
| §11 AnalyserResultatOCR.vi | Changer la case `-2` en `-1` et refaire le checkpoint 11.2 (changement 2) | Suivre la recette mise à jour |
| §12 LireCase.vi et la suite | Rien à refaire ; le checkpoint 12.3 donne en plus l'en-tête attendu | Suivre la recette mise à jour |

**À faire ensemble : OCR.exe recompilé et EcrireCellule.vi corrigé.** Nos cases sont rectangulaires (76×72 pour la première du 6×6). Avec un seul des deux côtés mis à jour, hauteur et largeur sont lues à l'envers et les cases contenant un chiffre tombent en code 5 (vérifié avec le C sur une case rectangulaire).

## Changement 1 — EcrireCellule.vi (§9.1, étape 1)

L'en-tête doit être écrit hauteur puis largeur : on intervertit deux fils, rien d'autre.

| Nœud | Avant (recette du 9.10) | Après (recette du 30.10) |
| --- | --- | --- |
| H1 `To Unsigned Long Integer` | reçoit la largeur (I2) | reçoit la **hauteur** (I1) |
| H2 `To Unsigned Long Integer` | reçoit la hauteur (I1) | reçoit la **largeur** (I2) |
| H3 `Build Array`, entrée 0 | largeur | **hauteur** |
| H3 `Build Array`, entrée 1 | hauteur | **largeur** |
| Donnée écrite par N2 | U32 [largeur, hauteur] | U32 [hauteur, largeur] |
| Checkpoint 9.3, matrice 55×60, 8 premiers octets | `[60,0,0,0,55,0,0,0]` | `[55,0,0,0,60,0,0,0]` |

1. Ouvrez EcrireCellule.vi, diagramme, case G1.No Error.
2. Intervertissez **soit** les deux fils qui entrent dans H1 et H2, **soit** les deux fils qui entrent dans H3. Pas les deux : cela reviendrait à l'ordre d'origine.
3. Ne touchez à rien d'autre : pas de transposition, M1/M2 (`Reshape Array`) inchangés, little-endian, prepend FALSE pour les deux écritures.
4. Refaites le checkpoint 9.3 : taille 3308 octets, huit premiers octets `[55,0,0,0,60,0,0,0]`, valeur 1 à l'index 137 (inchangé).
5. Corrigez l'étiquette de commentaire du diagramme si elle dit « largeur puis hauteur », puis enregistrez.

## Changement 2 — AnalyserResultatOCR.vi (§11.1, étape 7)

La case vide arrive maintenant en `-1` avec un vrai pourcentage : on renomme la case et on supprime le contrôle « score = 0 ».

| Élément | Avant (recette du 9.10) | Après (recette du 30.10) |
| --- | --- | --- |
| Cases du Case numérique sur `symbole` | 0, 1, **-2**, Default | 0, 1, **-1**, Default |
| Case vide → ValeurMatlab | chaîne `NaN` | chaîne `NaN` (inchangé) |
| Case vide → Pourcentage | score (devait valoir 0) | score = ratio de blancs, par ex. 88.166542 |
| Case vide → erreur | `ErreurSi(score≠0, 7005, Score de case vide invalide.)` + garde supplémentaire | erreur G4 directement, comme les cases 0 et 1 |

1. Ouvrez AnalyserResultatOCR.vi, Case numérique sur `symbole` dans G4.No Error.
2. Affichez la case `-2` et changez son libellé en `-1` dans le sélecteur de la Case.
3. Dans cette case, supprimez l'ErreurSi et sa garde. Câblez la chaîne `NaN` vers ValeurMatlab, `score` vers Pourcentage et l'erreur G4 vers la sortie erreur. N8 vérifie déjà que le score est entre 0 et 100.
4. Refaites le checkpoint 11.2. Deux lignes changent :

| Texte d'essai | Avant | Après |
| --- | --- | --- |
| `d:'-1', 88.166542%\n` | (pas testé) | `NaN`, 88.166542, sans erreur |
| `d:'-2', 0.000000%\n` | `NaN`, 0, sans erreur | erreur 7005 (case Default : ancien format refusé) |

Les autres lignes du checkpoint 11.2 donnent le même résultat qu'avant.

## Changement 3 — OCR.exe (§1.1)

Trois sources ont changé : copiez `main.c`, `reconnaissance.c` et `reconnaissance.h` de la branche main dans `Execution` (`parametres_ocr.h` et `FontRasterized_0_1.h` sont inchangés), puis recompilez avec la même commande qu'au §1.1.

| Essai (seuils 88 90 90) | Avant | Après |
| --- | --- | --- |
| `OCR.exe Cell0.bin` | `d:'0', 97.167969%` | inchangé |
| `OCR.exe Cell1.bin` | `d:'1', 97.753906%` | inchangé |
| `OCR.exe CellEmpty.bin` | `d:'-2', 0.000000%` | `d:'-1', 88.166545%` (Moodle : 88.166542 %, écart admis) |
| `OCR.exe BadCell_1.bin` | code 3, ancien CellValue.txt laissé en place | code 3, CellValue.txt vidé (0 octet) |
| Cell.bin rectangulaires ajoutés sur Moodle | mal lus (code 5) | reconnus comme les cellules carrées |

Nouveau code de retour 7 : 0 et 1 atteignent leur seuil avec le même score ou la même marge. Il n'apparaît pas avec les Binairos fournis ; LabVIEW le traite comme tout code non nul (erreur 7006).

## Recette : passages modifiés

La recette (md, html et pdf) a 23 passages modifiés, regroupés ci-dessous ; seuls ceux marqués **Modifier le VI** ou **Refaire le test** demandent une action si la partie est déjà faite.

| Passage | Avant (9.10) | Après (30.10) | Action |
| --- | --- | --- | --- |
| Début de la recette | Version du 9 octobre | Version du 30 octobre + encadré « Modifications du 30 octobre 2026 » | Lire |
| Règle OCR appliquée (introduction) | case vide testée en premier ; à marge égale, on garde 0 | chiffres d'abord, puis vide écrit `d:'-1', <ratio>%` ; égalité = code 7 | Lire |
| §1.1 résultats attendus | `d:'-2', 0.000000%` | `d:'-1', 88.166545%` | **Refaire le test** |
| §1.1 essai BadCell_1 | « sans utiliser le précédent résultat » | CellValue.txt vidé (0 octet) ; tester aussi les Cell rectangulaires | **Refaire le test** |
| §2.2 Tableaux | « le fichier C commence par largeur, hauteur » | « même ordre : hauteur, largeur » | Lire |
| §3 seuils et scores | garde 0 à marge égale ; vide prioritaire ; 3 warnings | code 7 à égalité ; vide après les chiffres, en `-1` ; 4 warnings avec leurs codes | Lire |
| §9 But | « sans inverser largeur et hauteur » | « en-tête hauteur puis largeur » | Lire |
| §9.1 étape 1 | H1 = largeur, H2 = hauteur, U32 [largeur,hauteur] | H1 = hauteur, H2 = largeur, U32 [hauteur,largeur] | **Modifier le VI** |
| §9.2 dernier paragraphe | en-tête « dans l'ordre du C » | en-tête écrit hauteur puis largeur | Lire |
| §9.3 étape 4 | `[60,0,0,0,55,0,0,0]` | `[55,0,0,0,60,0,0,0]` | **Refaire le test** |
| §11.1 étape 7 | cases 0,1,-2,Default | cases 0,1,-1,Default | **Modifier le VI** |
| §11.1 tableau, ligne de la case vide | -2 → NaN, score, ErreurSi(score≠0…) | -1 → NaN, ratio de blancs, erreur G4 | **Modifier le VI** |
| §11.1 phrase sous le tableau | garde supplémentaire dans -2 | pas de garde dans -1 | **Modifier le VI** |
| §11.2 deux lignes du tableau | `d:'-2', 0.000000%\n` → NaN,0 ; `d:'-2', 1.000000%\n` → 7005 | `d:'-1', 88.166542%\n` → NaN,88.166542 ; `d:'-2', 0.000000%\n` → 7005 | **Refaire le test** |
| §12.3 checkpoint | Résultat NaN | + 8 premiers octets `[72,0,0,0,76,0,0,0]` ; pourcentage = ratio de blancs > 88 | Vérifier en le faisant |
| Ch. 20 Si quelque chose ne marche pas | « largeur/hauteur dans cet ordre » | « hauteur puis largeur » ; ordre de l'en-tête ajouté aux causes d'« OCR code 5 partout » | Lire |
| Ch. 23 État de cette recette | 116 cellules reconnues | mesure faite avec la version du 9.10, à refaire sur la VM | Lire |
| Annexe G4, étape 7 | « écrira largeur puis hauteur » | « écrira hauteur puis largeur » | Lire |
| Annexes Mise à jour, Contrôles de remise, H1 | C ne vide pas CellValue.txt ; codes 0 à 6 ; vide puis score | C vide CellValue.txt ; codes 0 à 7 ; score puis vide | Lire |

Le PDF de la recette a été régénéré depuis la version HTML : même contenu, mise en page différente (73 pages au lieu de 49).

## Inchangé

Ne touchez pas au reste : ces parties fonctionnent telles quelles avec le nouveau C.

- Découpage des cases (annexe G, `Array Subset` du §12.2) : pas de transposition, les dimensions restent mesurées pareil.
- Seuils 88/90/90 et CommandeOCR.vi (§10).
- Suppression de CellValue.txt avant chaque appel et contrôle du code de retour et de stderr dans LireCase.vi (§12.3).
- GenererScript.vi et solve.m, LancerMatlab.vi, VerifierPDF.vi, BinairoSolver.vi.
- Les sept fonctions MATLAB : la matrice reçoit toujours 0, 1 ou NaN.
