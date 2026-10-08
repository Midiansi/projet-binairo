# Techniques utilisées et références des cours

8 octobre 2026 — ME-213 et CS-119a (semestre précédent)

Ce tableau relie les **techniques des sources C/MATLAB et des diagrammes décrits** aux cours fournis. Le projet combine ces techniques pour résoudre un nouvel exercice : il ne prétend pas que chaque ligne a été recopiée d’une diapositive. Les pages sont physiques, à partir de 1. Les fichiers originaux des cours ne sont pas redistribués dans le dépôt.

## C

| Technique dans le projet | Référence fournie | Utilisation |
|---|---|---|
| Conditions, boucles, tableaux, fonctions, pointeurs, chaînes terminées par NUL | CS-119a `cours2.pdf` à `cours7.pdf`, exemples `while_number_of_digits.c`, `strings_argc_argv.c`, `pointers_and_arrays.c` ; ME-213 C1 | parcours des arguments et des pixels, validation, fonctions auxiliaires |
| Conversion d’un entier par les chiffres, multiplication par 10 et addition | opérations/arithmetic et boucles des cours précédents ; `while_number_of_digits.c` pour le parcours des chiffres | ConvertirSeuil : refus des fractions et bornes 1..99, sans parseur externe |
| Structures et pointeurs vers structures | CS-119a `cours8.pdf`, p. 18–29 ; `structs_and_ptrs.c` | CelluleOCR, SeuilsOCR, ResultatOCR |
| malloc/free, allocation selon la taille connue | CS-119a `cours7.pdf`, p. 10–11 et 29 ; `dynamic_array.c` ; ME-213 C5 | pixels et chemins ; aucun VLA |
| fopen/fread/fgetc/fprintf/ferror/fclose | ME-213 `C3.PPI_C_Fichiers.26.r1.pdf`, p. 13–26 ; CS-119a `cours11.pdf` et `cours12.pdf` | lecture binaire groupée, détection des troncatures/excès, texte de sortie, erreurs |
| fflush | CS-119a `cours12.pdf`, p. 12 | détecter l’échec du vidage du tampon de sortie |
| strlen/strcmp/memcpy | CS-119a `cours12.pdf`, p. 21,23,25–26 ; `strings_strlen.c`, `strings_strcmp.c` | construire le chemin voisin CellValue.txt sans modifier l’entrée |
| Types entiers de largeur fixée, octets et ordre des octets | ME-213 C3, p. 27 et 30–34 ; donnée Binairo, p. 20–22 | uint32_t, décodage little-endian |
| Décalages et masques binaires | ME-213 `C2.PPI_C_RepresentationNombre+BitWiseOp.26.r1.pdf`, p. 13–16 | GetDigitBitmapBit et lecture de l’en-tête |
| static, const, durée de vie | ME-213 `C5.PPI_C_IntroMemoryMgmt.26.r1.pdf`, p. 8–9 ; rappels C | nom constant de sortie |
| goto uniquement vers le nettoyage final | ME-213 `C4.PPI_C_SoftwareEngineering.26.r1.pdf`, p. 21–23 | un chemin de fermeture/libération en cas d’erreur |
| Balayage des deux modèles 32×32, test du vide puis score/marge | donnée Binairo 2026.2, p. 7–18 | algorithme expressément demandé |

La mise à jour des seuils utilise uniquement caractères, entiers, if/while et arithmétique. Le contrôle après chaque chiffre empêche le débordement de l’accumulation. Les structures et interfaces existantes restent identiques.

## MATLAB

| Technique/fonction dans les sept fichiers | Référence fournie | Utilisation |
|---|---|---|
| Matrices, produits, transposition, indexation, masques logiques, concaténation | `M1.PPI_Matlab_I.26.r1.pdf`, p. 15–29 | comptes, répétition d’une ligne/colonne, comparaison simultanée et tracé sans boucles |
| find, ind2sub, isnan, sum, any, isequal | `Exo.Proj.Binairo.Matlab.2.pdf`, p. 1 ; M3 p. 12 pour ind2sub | fonctions explicitement proposées pour ce projet |
| if, fonctions locales, arguments/retours, isa | `M2.PPI_Matlab_II.26.r1.pdf`, p. 27–41 | validation et découpage en fonctions |
| Récursion et retour en arrière | donnée Binairo p. 29 et 33–34 ; exercice de récursion ; CS-119a `cours13.pdf`, p. 5–7 et 18–21, `cours14.pdf` | essais 0 puis 1 et reprise de la grille de base |
| Diviser un parcours en deux parties récursives | CS-119a théorie `icc_cours3_handout.pdf`, p. 12–24 (dichotomie/tri fusion) | ParcourirCases conserve l’ordre mais limite la profondeur du parcours ; aucune bibliothèque de recherche |
| numel et isempty | `Demo_matlab.zip`, `Demo_Matlab_4_8_Integral_SimpsonRec.m` ; pour isempty aussi `Demo_Matlab_4_4c_DemoAntOutsideThePlate.m` | taille et absence d’éléments |
| floor | `Demo_matlab.zip`, `Demo_Matlab_4_x_CellArray_SegmentGetCentralIdx.m` | milieu entier d’un intervalle |
| Cell arrays et concaténation de cellules | M3 p. 15–19 | découper le nom long en lignes de texte |
| meshgrid | M3 p. 28–30 | coordonnées de toutes les cases |
| figure, axes, handles et propriétés graphiques | M2 p. 42–50 ; `Demo_Matlab_2_5_PlotRef.m` | placement, couleurs, tailles et propriétés du dessin |
| line | `Demo_Matlab_2_1_edit_debug.m`, et démonstrations d’animation de ressort dans Demo_matlab.zip | traits horizontaux et verticaux |
| text, axis, datetime, num2str, print | `Exo.Proj.Binairo.Matlab.1.pdf`, p. 2 | fonctions explicitement proposées pour le PDF ; char convertit la date en texte |
| close, drawnow | `Demo_Matlab_4_15a_ODE45_Unforced_DampedSpring_Animation.m` | rafraîchir/fermer la figure sans toucher aux autres figures |
| fprintf et error | M2 p. 32 ; M3 p. 51 ; squelette SolveBinairoHeader | messages et remontée des erreurs |
| uiopen | addendum du 7 octobre, p. 14 | ouvrir le PDF si demandé |

Le produit des masques 0/1 dans GrilleBinairoValide n’introduit pas une nouvelle bibliothèque : il applique le produit matriciel enseigné pour compter les positions égales. Une somme égale à n implique deux lignes complètes identiques. Les récursions, opérations matricielles et signatures du squelette sont conservées. Aucun arrayfun/cellfun, classe, toolbox d’optimisation, solveur externe ou boucle explicite n’est ajouté.

Le script `tests/VerifierMatlab.m` emploie les mêmes fonctions, comparaisons, if et error. Il est à exécuter dans MATLAB ; son existence ne vaut pas un résultat de test.

## LabVIEW

| Construction décrite dans la recette | Référence fournie |
|---|---|
| Types, conversions, tableaux/clusters, For/Case, Select | `LV1.PPI_LabVIEW_intro1.26.r1.pdf`, p. 28–47,59–61,71 et 75–76 |
| Registres à décalage et propagation d’erreurs | `LV2.PPI_LabVIEW_intro2_SR_Files.26.r1.pdf`, p. 3,8–10,18–20 ; exercice Loops/TunnelMode/ShiftRegister |
| Chaînes, String Subset, Search and Replace, Format Into String, Scan From String | LV2 p. 45–50 |
| Fichiers texte/binaires, ouvrir/écrire/fermer | LV2 p. 24–31 ; exercice Binairo LabVIEW 1, p. 9–14 |
| System Exec et gestion de son retour | LV2 p. 51 ; exercice Binairo LabVIEW 1 p. 13–14 ; LabVIEW 2 p. 2–7 |
| Lecture PNG, Picture to Pixmap, Unflatten Pixmap, Index Array, Array Subset | exercice Binairo LabVIEW 1 p. 3–8 |
| Chemins relatifs au VI, Build Path | même exercice p. 10–11 |
| Compter transitions et traiter les traits aux bords | donnée p. 27 ; exercice LabVIEW 1 p. 15–16 |
| Nouveau calcul du rectangle | indexation des traits, soustractions, comparaisons et Select des cours ci-dessus ; pas de morphologie ou de traitement d’image ajouté |
| Parseur OCR sans expression régulière | Scan From String puis Format Into String et égalité de chaînes, LV2 p. 47–48 |
| Génération de solve.m | LabVIEW 2 p. 2–5, chaînes/formats de LV2 |
| Suppression d’un ancien résultat, contrôle d’existence/type et d’erreur | fichiers/chemins/erreurs de LV2 ; détails des bornes via Context Help, comme demandé dans l’exercice |

Les détails des **bornes et options des fonctions natives** se vérifient avec Context Help et la documentation NI, comme le demandent les exercices. Ce sont des paramètres d’utilisation des fonctions du cours, pas un nouveau paradigme. Les fonctions de lecture d’image et les opérations de fichier restent natives. La recette ne demande ni Python, ni .NET, ni ActiveX, ni IMAQ, ni DLL externe, ni expressions régulières. Les commandes du compilateur et les fichiers projet sont des moyens de construction, pas du code d’algorithme à étudier.

## Changements pour rester dans ce cadre

- Le parseur numérique C est simplifié en lecture de chiffres ; aucune nouvelle fonction de bibliothèque n’est nécessaire.
- Les trois usages d’expressions régulières ont été retirés de la recette : format OCR et deux contrôles de chemins sont maintenant faits avec chaînes, For/Case et comparaisons.
- Le lancement MATLAB utilise System Exec directement, comme l’exécutable C ; la recette n’a plus de commande imbriquée cmd /c.
- La correction du crop utilise seulement quatre épaisseurs, Less?/Select, Add/Subtract et Array Subset.
- Les fonctions MATLAB de calcul sont inchangées. Leur fondement est documenté ci-dessus ; aucune technique supplémentaire n’est introduite pour contourner l’absence de boucles.

Les outils utilisés pour préparer les documents et effectuer les contrôles indépendants ne sont pas des dépendances du programme étudiant et ne sont pas requis dans la VM. Les résultats indépendants sont identifiés comme tels ; ils ne remplacent jamais une exécution native MATLAB/LabVIEW.
