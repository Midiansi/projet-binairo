# Documentation projet — BROUILLON à compléter sur la VM

> Brouillon préparé pendant l’audit du 16 novembre 2026, d’après le modèle Moodle `ExempleDocumentationProjet.2026.pdf`. Les parties C et MATLAB décrivent le code actuel. Tout ce qui est marqué **À COMPLÉTER** doit être relevé ou vérifié sur la VM avant l’export en PDF. Cinq pages au grand maximum (Ed #35). Supprimez cet encadré dans la version remise.

**Titre projet :** Binairo 2026

**Auteurs :** Louis Pédelaborde, Romeo Mugnier de Almeida, Raphaël Pical

Les noms des auteurs sont renseignés dans tous les fichiers sources : **À COMPLÉTER** (vrai pour les fichiers C et MATLAB ; à vérifier dans `VI Properties > Documentation` de chaque VI)
L’archive soumise contient tous les fichiers demandés (éventuellement plus) : **À COMPLÉTER**
L’archive soumise contient un jeu de fichiers pdf résultats : **À COMPLÉTER**

**Le projet doit être évalué sur :** VM

| | |
| --- | --- |
| OS + version | **À COMPLÉTER** (`winver`) |
| Plateforme de test | VM STI_Windows11 |
| Compilateur C + version | **À COMPLÉTER** (Visual Studio, `Help > About`), configuration Release x64, `/O2`, `/MT` |
| Matlab + version | **À COMPLÉTER** (`version`) |
| LabVIEW + version | **À COMPLÉTER** (`Help > About LabVIEW`, attendu 2025 Q3) |

## Liste des fichiers

**C :** `main.c` (arguments, chemin de sortie, écriture de `CellValue.txt`) ; `reconnaissance.c` / `reconnaissance.h` (lecture de `Cell.bin`, comparaison aux modèles, choix du symbole) ; `parametres_ocr.h` (bornes) ; `FontRasterized_0_1.h` (police fournie, non modifiée) ; `OCR/OCR.sln`, `OCR/OCR.vcxproj` (projet Visual Studio).

**LabVIEW :** `BinairoSolver.vi` (programme principal) ; **À COMPLÉTER** : liste réelle des sous-VIs et des `.ctl`.

**MATLAB :** `solve.m` (script créé par LabVIEW) ; `SolveBinairo.m` (résolution, avec les fonctions locales `DirectValues`, `ParcourirCases`, `CheckValidMove`, `CheckVectorOk`, `CheckVectorUniqueOk`, `printGrid`) ; `DisplayBinairo.m` et `DispBinairo.m` (PDF) ; `CreerFigureBinairo.m` (dessin) ; `CheminPdfBinairo.m` (nom du PDF) ; `FormatGrilleValide.m`, `GrilleBinairoValide.m` (contrôles).

**Autres :** `OCR.exe` (exécutable Windows x64) ; `Resultats/<image>/` : `Cell.bin`, `CellValue.txt`, `solve.m`, `Binairo_XXX.pdf` produits sur la VM ; `Transcripts_IA/` : conversations avec les assistants IA.

## Flux de données

`Binairo_XXX.png` → **BinairoSolver.vi** (lecture, conversion noir/blanc, comptage des traits, découpe d’une case) → `Cell.bin` → **OCR.exe** `"<dossier>\Cell.bin" 88 90 90` → `CellValue.txt` → BinairoSolver.vi (une valeur `0`, `1` ou `NaN` par case) → `solve.m` → **MATLAB** (`SolveBinairo`, `DisplayBinairo`) → `Binairo_XXX.pdf`. Tous les fichiers sont dans le dossier de `BinairoSolver.vi` ; aucun chemin absolu n’est enregistré.

`Cell.bin` : hauteur (uint32, little-endian), largeur (uint32), puis hauteur × largeur octets valant 0 (blanc) ou 1 (noir), ligne par ligne. `CellValue.txt` : `d:'<symbole>', <pourcentage à six décimales>%` suivi d’une fin de ligne ; le symbole vaut `0`, `1` ou `-1` (case vide). `CellValue.txt` est écrit dans le dossier de `Cell.bin`.

## Algorithme C

1. Vérifier les cinq arguments ; retirer d’éventuels guillemets ou apostrophes autour du chemin ; convertir les trois seuils (entiers de 1 à 99).
2. Lire l’en-tête, vérifier les dimensions, allouer le tableau (`malloc`) et lire tous les pixels en une fois.
3. Pour chaque chiffre 0 et 1 : déplacer le modèle 32×32 sur toutes les positions de la case, compter les pixels identiques (noirs et blancs), garder le maximum, le convertir en pourcentage de 1024.
4. Retenir les chiffres dont le pourcentage est ≥ leur seuil. S’il y en a deux, choisir la plus grande marge `pourcentage − seuil` (donnée, p. 18). Le pourcentage écrit est le pourcentage brut.
5. Si aucun chiffre n’est retenu : la case est vide si le pourcentage de pixels blancs est > seuil vide (ordre demandé le 30.10.2026). Le pourcentage écrit est alors celui des blancs.
6. Écrire `CellValue.txt`.

## Gestion des erreurs en C

Le code de retour vaut 0 en cas de succès. Sinon un message `OCR E<code>: …` est écrit sur `stderr`, rien n’est écrit sur `stdout`, et `CellValue.txt` est vidé (0 octet) quand c’est possible.

| Situation | Comportement |
| --- | --- |
| Nombre d’arguments différent de 4 | code 2, arrêt, `CellValue.txt` non créé |
| Seuil hors de [1..99], non entier ou non numérique | code 2, arrêt |
| Chemin vide, de plus de 1023 caractères, ou nommé `CellValue.txt` | code 2, arrêt |
| `Cell.bin` impossible à ouvrir ou à lire | code 4, arrêt |
| Largeur ou hauteur hors de [50..1000] | code 3, arrêt |
| Pas assez de pixels (1 à N manquants), en-tête incomplet | code 3, arrêt |
| **Trop de pixels** (warning de l’addendum) | traité comme une erreur : code 3, arrêt |
| Pixel différent de 0 et 1 | code 3, arrêt |
| **Ni vide, ni 0, ni 1** (warning) | code 5, arrêt |
| **0 et 1 au-dessus de leur seuil** (warning) | la plus grande marge gagne ; à égalité de pourcentage ou de marge : code 7, arrêt (Ed #7) |
| `CellValue.txt` impossible à ouvrir ou à écrire | code 6, arrêt |

Conséquence de l’ordre « chiffres d’abord » : avec un seuil de chiffre très bas (≤ 80 pour le 1), une case vide est lue comme un chiffre. Avec les seuils fournis 88/90/90, les trois fichiers Moodle donnent `d:'0', 97.167969%`, `d:'1', 97.753906%`, `d:'-1', 88.166542%`.

## Algorithme LabVIEW

**À COMPLÉTER** (quelques lignes) : lecture PNG et conversion 1 bit ; premier trait noir + 10 pixels ; comptage des traits horizontaux et verticaux, nombre de cases = traits − 1, refus si lignes ≠ colonnes ou nombre impair ; découpe de chaque case à l’intérieur des traits ; écriture de `Cell.bin`, appel d’`OCR.exe`, lecture de `CellValue.txt` ; construction de la matrice ; écriture de `solve.m` ; lancement de MATLAB ; vérification du PDF.

## Gestion des erreurs en LabVIEW

**À COMPLÉTER** avec les codes réellement câblés et le comportement observé sur la VM :

| Situation | Comportement |
| --- | --- |
| Fichier choisi absent, non `.png`, ou PNG illisible (`BadBinairo.png`) | **À COMPLÉTER** |
| Grille non carrée ou de taille impaire (`Binaro_5x6_Bad.png`) | **À COMPLÉTER** |
| `OCR.exe` manquant ou renommé | **À COMPLÉTER** |
| Code de retour d’OCR non nul ou texte sur `stderr` | **À COMPLÉTER** |
| `solve.m` impossible à écrire | **À COMPLÉTER** |
| MATLAB introuvable | **À COMPLÉTER** |
| Erreur dans le script MATLAB | **À COMPLÉTER** |
| PDF absent après l’exécution | **À COMPLÉTER** |

## Algorithme MATLAB

`SolveBinairo` vérifie d’abord la grille (carrée, taille paire, valeurs 0, 1 ou NaN, règles respectées). `DirectValues` remplit sans deviner toutes les cases où une seule valeur est possible, jusqu’à ce que la grille ne change plus ; une case sans valeur possible signale une contradiction. S’il reste des cases vides, `SolveBinairo` essaie 0 puis 1 dans la première et s’appelle récursivement ; un échec ramène à la grille d’avant l’essai. Les règles sont testées sur des vecteurs entiers (sommes, comparaisons décalées, produits matriciels) : le code ne contient aucune boucle `for` ou `while` ; le parcours des cases vides se fait par récursion.

`DisplayBinairo` dessine la grille (indices initiaux en noir gras, valeurs trouvées en bleu gras, nom du fichier source en haut à gauche, date et heure en haut à droite, `== Error ==` au centre si la grille n’a pas de solution) et l’enregistre dans `Binairo_XXX.pdf`.

Option « Résoudre » décochée : MATLAB dessine la grille reconnue sans la résoudre. Option « Ouvrir le PDF » : **À COMPLÉTER** (ouverture par `uiopen` depuis MATLAB ou par LabVIEW, selon ce qui fonctionne sur la VM).

## Autres informations utiles, problèmes rencontrés

- Aide IA : des assistants IA ont été utilisés pour le code C et MATLAB, la recette de construction LabVIEW et un audit ; les conversations complètes sont jointes en PDF dans `Transcripts_IA`. **À COMPLÉTER** : liste des outils et des dates.
- Sources externes et collaboration avec un autre groupe : **À COMPLÉTER** (à déclarer s’il y en a).
- **À COMPLÉTER** : messages MATLAB ignorés, durée d’exécution, points observés sur la VM.
