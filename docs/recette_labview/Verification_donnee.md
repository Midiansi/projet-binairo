# Vérification du projet contre la donnée Binairo 2026.2

22 septembre 2026. Référence prioritaire : **Donnée projet Binairo 2026.2**, fichier `P00.PPI_Projet.2026.2.pdf`, version du 7 septembre 2026. Le titre et le lien ont été vérifiés dans l’index de l’export Moodle. Les pages ci-dessous sont les pages physiques du PDF ; la page physique18 porte le numéro imprimé17.

Les exercices ne remplacent pas cette donnée. Ils restent utilisables pour les exemples, les fichiers fournis et les détails qui ne la contredisent pas. Les critères généraux de notation2025 restent applicables selon la confirmation du professeur rapportée par le groupe ; aucune exigence technique propre au Billard n’est importée.

## Écarts corrigés

| Point | Ancien état | Correction | Source |
|---|---|---|---|
| Chiffre dont le score égale son seuil | rejeté par `>` | accepté par `>=` | donnée p18, étape3 |
| Deux chiffres admissibles, seuils différents | meilleur score brut | plus grande marge `score - seuil` ; le résultat écrit conserve le score brut | donnée p18, étape3 |
| Argument du programme OCR dans la recette | `Cell.bin` relatif, avec dossier de travail | chemin complet calculé depuis le dossier du VI ; chemin complet de l’exécutable également, tous deux entre guillemets | donnée p23 |
| Lancement MATLAB | recours au VI de l’exercice présenté comme obligatoire pour terminer | lancement direct complet par défaut ; VI fourni facultatif, sans en inventer les bornes | donnée p26 et36 |
| Comptage des cases | nombre de débuts de traits moins1, mathématiquement équivalent | formulation littérale : total des transitions/2−1 pour chaque axe | donnée p27 |
| Statut des exercices | certaines conventions présentées comme exigences du projet | donnée explicitement prioritaire ; noms de sous-VIs et lanceur de l’exercice identifiés comme aides compatibles | donnée p3 et27 ; instruction du groupe |

Le changement C est limité à `ChoisirChiffre` et au message d’absence de candidat dans `reconnaissance.c`. Les codes de retour, allocations, fichiers, formats et limites restent identiques. Aucun changement MATLAB n’est nécessaire d’après la relecture des exigences de la donnée.

## Couverture de la donnée

| Pages | Exigence vérifiée | Implantation ou construction | Conclusion |
|---|---|---|---|
| 2,5–6 | C pour l’OCR ; LabVIEW pour image et orchestration ; MATLAB pour résolution/PDF ; échanges par fichiers | architecture actuelle et recette17 | respecté dans les sources et le plan de construction |
| 7–12 | octets0/1, blanc/noir ; police fournie32×32 ; balayage pixel par pixel ; compter les blancs et noirs égaux ; tester le vide en premier | GetDigitBitmapBit, GetCellBit, ReconnaitreCellule | conservé ; exemples et116 cellules testés localement |
| 15–16,20–22 | largeur puis hauteur, uint32 petit-boutiste ; pixels unsigned char ligne par ligne ; lecture groupée et allocation dynamique | LireCellule ; EcrireCellule.vi, chapitre9 | respecté dans C ; checkpoint binaire LabVIEW à exécuter |
| 17 | valeur reconnue et pourcentage dans CellValue.txt, puis fin de ligne | main.c ; AnalyserResultatOCR.vi | syntaxe respectée ; six décimales et valeur vide−2 précisés par les exemples Moodle compatibles |
| 18 | candidats au seuil inclus et sélection par marge | ChoisirChiffre corrigé | testé avec égalité réelle, seuils différents, marges égales et aucun candidat |
| 19 | dimensions raisonnables10..100 ; nombre exact de pixels ; erreurs d’ouverture/création | LireCellule et main.c | contrôles déjà présents, conservés |
| 23 | chemin complet de cellule et trois seuils ; argc=5 | main.c ; CommandeOCR.vi corrigé | appel C testé avec chemin complet contenant des espaces ; appel natif LabVIEW à vérifier |
| 24–27 | interface source/image/options/erreurs ; PNG lu et converti nativement ; comptage pair/carré ; découpage ; OCR ; matrice texte ; script généré et exécuté | chapitres7–17 et annexeG | chaque opération possède une construction ; pas d’exécution LabVIEW revendiquée |
| 27 | transitions, axes environ10px après le bord ; nombre pair et égal de cases | IntervallesNoirs et ComputeRowsCols | formule rendue littérale ; coordonnées contrôlées séparément sur les images fournies |
| 28–31,33–34 | règles du Binairo ; déductions répétées jusqu’à stabilisation ; puis essai0 et1 avec récursion ; NaN pour vide | SolveBinairo, DirectValues, CheckValidMove, CheckVectorOk, CheckVectorUniqueOk | conforme par relecture ; aucune modification MATLAB |
| 32 | DisplayBinairo(Original,Solution,file,...) ; indices noirs gras, ajouts bleus gras ; traits ; nom haut gauche, date/heure haut droite ; == Error == centré | DisplayBinairo et CreerFigureBinairo | propriétés présentes dans le code ; rendu natif à vérifier |
| 33–35 | fonctions auxiliaires et printGrid ; appels depuis un script généré | fonctions présentes ; GenererScript→ExecuterBinairo→SolveBinairo/DisplayBinairo | le passage par l’auxiliaire ExecuterBinairo conserve les fonctions prescrites ; aucun script fixe ne remplace la matrice reconnue |
| 36 | OCR absent/en erreur, PNG absent, script impossible à créer, MATLAB absent, script MATLAB en erreur | gestion d’erreurs C ; recette5,6,12,15–19 | chaque cas possède un essai natif identifié ; résultats natifs encore attendus |

## Contradictions internes et conventions restantes

- **Score brut contre marge :** la page10 de la donnée décrit le score brut, tandis que la page18 définit explicitement la marge. Le code suit maintenant **la procédure détaillée de la page18**, et non l’exercice. Il serait inexact de déclarer ces deux passages simultanément respectés lorsque les seuils diffèrent. La question de confirmation dans la recette cite cette contradiction précise.
- **Égalité des marges :** aucun départage n’est prescrit. À marges exactement égales, le programme conserve0, premier chiffre essayé. Le pourcentage retourné est toujours son score, jamais sa marge.
- **Case vide :** test prioritaire et strict `ratio de blancs > seuil vide` selon p10. L’égalité incluse de p18 concerne les chiffres0/1, pas le vide.
- **Noms MATLAB :** la donnée emploie plusieurs graphies dans ses titres, mais donne la signature explicite DisplayBinairo p32 et SolveBinairo p33–34. Ces fonctions sont présentes ; DispBinairo reste un alias compatible avec l’appel de p35. `solve.m` est conservé selon les chemins/fichiers demandés p6,26,35 malgré la majuscule de certains titres.
- **Connecteur principal et codes d’erreur :** aucun connecteur Binairo définitif ni tableau exhaustif des codes n’est fourni dans la donnée reçue. Les connecteurs et codes locaux sont documentés comme choix du projet ; ceux du Billard ne sont pas repris. La page36 annonce une liste d’erreurs ultérieure : la version locale exportée ne prouve pas qu’aucun complément n’a été publié depuis.
- **Réglages OCR :** 98/90/90 pour les cellules intérieures découpées, 88/90/90 uniquement pour les trois fichiers binaires fournis. Ce sont des réglages validés sur ces exemples, pas des valeurs déclarées officielles. Les seuils restent réglables.

## Vérifications réellement exécutées

- Compilation C avec `-std=c11 -Wall -Wextra -Wpedantic -Werror -Wvla` : aucune erreur ni avertissement.
- Huit tests ciblés de sélection : égalité au seuil pour chacun des deux chiffres, marge donnant un gagnant différent du score brut, égalité de marges, seuil100 et absence de candidat.
- Cent seize appels OCR sur les cellules découpées des PNG6×6,8×8 et4×4 ; matrices reconnues comparées aux indices attendus.
- Neuf appels C supplémentaires : les trois exemples binaires Moodle, les deux modèles exacts à score100/seuil100, deux cas de vide au seuil strict, une égalité au seuil sur Cell0 et une sélection par marge sur Cell0 avec vérification du pourcentage écrit.
- Ces essais C ont utilisé AddressSanitizer et UndefinedBehaviorSanitizer : aucun diagnostic.
- Relecture des allocations et tableaux : pas de VLA ni de tableau déclaré par le projet dépassant100 éléments ; police originale2×32=64 éléments. Les chemins restent alloués par malloc, avec limite1023 caractères.
- Relecture des fonctions MATLAB, sans les exécuter ; vérification des chaînes et branchements modifiés de la recette. Ni MATLAB, ni LabVIEW, ni une VM n’ont été opérés.

## Si vous aviez déjà commencé la construction

1. Reprendre le C corrigé et recompiler OCR.exe sur Windows.
2. Au chapitre10, ajouter l’entrée Dossier à CommandeOCR.vi, construire les deux chemins complets et remplacer le format de commande. Au chapitre12, brancher LireCase.Dossier vers cette nouvelle entrée.
3. Dans ComputeRowsCols, appliquer le calcul explicite du pointG5.4.6. Les dimensions reconnues restent identiques.
4. Enregistrer Lanceur fourni=FALSE comme défaut et suivre le mode direct15.2. Le chapitre14 devient facultatif.
5. Refaire les essais du chapitre19 dans l’environnement réel. Ne pas marquer un essai réussi sur la seule base de ce rapport.

Les sources restent dans la livraison réservée aux `.c/.h/.m`. Ce rapport et la recette restent à part. Aucun document original du cours n’a été modifié.
