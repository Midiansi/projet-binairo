# Compilation du programme OCR

Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical

## Fichiers necessaires

Le dossier c contient main.c, reconnaissance.c, reconnaissance.h,
parametres_ocr.h et FontRasterized_0_1.h. Le dernier est le fichier original
fourni par le professeur : le conserver sans modification. Il est inclus
dans ce ZIP, mais reste exclu du depot GitHub.

## Windows avec Visual Studio

Ouvrir Developer Command Prompt for Visual Studio, puis se placer dans c :

    cd /d "chemin vers le dossier extrait\c"
    cl /nologo /std:c11 /W4 /TC main.c reconnaissance.c /Fe:OCR.exe

Utiliser une version prenant en charge /std:c11. _CRT_SECURE_NO_WARNINGS
est defini dans les deux fichiers .c avant les inclusions : fopen reste
utilise comme dans le cours. Cette compilation MSVC doit etre effectuee
sur la VM ; elle n'a pas ete executee sur le Mac de preparation.

Pour creer un projet dans Visual Studio : choisir Empty Project (C++),
nommer le projet OCR, ajouter les deux .c dans Source Files et les trois
.h dans Header Files, puis regler C/C++ > Advanced > Compile As sur
Compile as C Code (/TC) et C/C++ > Language > C Language Standard sur
ISO C11. Compiler et conserver le .vcxproj genere pour le rendu.

## GCC ou Clang

Depuis le dossier c :

    cc -std=c11 -Wall -Wextra -Wpedantic -Werror -Wvla main.c reconnaissance.c -o OCR

Sous Windows avec GCC, utiliser gcc au lieu de cc et -o OCR.exe.
Ne pas renommer un executable macOS en .exe : recompiler sous Windows.

## Verification et utilisation

Copier Cell0.bin depuis Moodle dans un dossier d'essai. Depuis ce dossier,
appeler OCR avec le chemin de Cell0.bin puis les seuils vide, zero, un :

    "chemin vers OCR.exe" "chemin complet vers Cell0.bin" 88 90 90

Sous cmd, lire echo %ERRORLEVEL% : resultat attendu 0. CellValue.txt est
cree a cote du fichier d'entree ; il doit contenir d:'0', 97.167969%
suivi d'une fin de ligne. Pour une erreur, le code est non nul et un
message est ecrit sur stderr. Ne pas utiliser un ancien resultat apres
une erreur. CellValue.txt est le fichier de sortie reserve du programme.

Une paire de guillemets simples ou doubles encore presente dans argv[1]
est retiree avant la lecture. Sous cmd, les apostrophes seules ne groupent
pas un chemin avec espaces : employer les guillemets doubles ci-dessus.
La limite reste 1023 caracteres pour le chemin apres retrait de la paire.

## Contenu et limites du paquet

Le ZIP contient les sources C/MATLAB et cette note de compilation. La
recette LabVIEW est fournie separement. Il ne contient pas encore les VIs,
le projet Visual Studio, l'executable Windows ni les resultats natifs :
il ne constitue pas a lui seul le rendu final complet du projet.
