# Projet Binairo — ME-213

Sources et recette corrigées suivant l’addendum du **7 octobre 2026**. Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical.

- [Recette LabVIEW, HTML avec sommaire et copie](docs/recette_labview/Recette_LabVIEW_Binairo.html), [PDF](docs/recette_labview/Recette_LabVIEW_Binairo.pdf), [Markdown](docs/recette_labview/Recette_LabVIEW_Binairo.md).
- [Compiler le C](docs/compilation/Compilation_C.md) ; projet Visual Studio dans `c/OCR.sln`.
- [Techniques et références ME-213/CS-119a](docs/Conformite_programme.md).
- [Vérifications et migration](docs/recette_labview/Verification_donnee.md).
- [Documentation courte, état de préparation](docs/Documentation_projet.md).

Le programme C utilise des dimensions 50..1000 et des seuils entiers 1..99. Valeurs par défaut : 88/90/90. Les sept fonctions MATLAB restent dans `matlab/`. `tests/VerifierMatlab.m` est un contrôle natif à copier dans le dossier d’exécution ; il ne remplace pas le script généré par LabVIEW.

Le binaire `bin/macos-arm64/OCR` est compilé et testé sur macOS Apple Silicon. Pour la recette Windows, compiler OCR.exe sur la VM. Les VIs doivent encore être construits et les essais MATLAB/LabVIEW exécutés : **ce dépôt n’est pas encore une archive de remise validée**. Le chapitre 21 explique comment conserver les sorties, réunir les fichiers et retester l’archive téléchargée.
