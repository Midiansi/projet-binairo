# Projet Binairo — ME-213

Sources et recette corrigées suivant l’addendum du **7 octobre 2026**. Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical.

Le dépôt garde **trois dossiers à la racine** :

```text
c/       sources C, projet Visual Studio et binaire OCR
matlab/  les sept fonctions MATLAB du projet
temp/    recette, documentation, contrôles et préparation du rendu
```

Les documents sont dans `temp/docs/` et les tests dans `temp/tests/`. Lors de la construction des VIs, créer `temp/Execution/` pour le programme intégré, `temp/Preuves/` pour les résultats et `temp/Images/` pour les entrées de test. Ces trois derniers dossiers sont créés au fil des essais ; aucun VI ou résultat natif n’est encore fourni. `Execution` garde côte à côte les dépendances attendues par la recette, copiées depuis `c/` et `matlab/`.

Pour la remise, conserver la même organisation `c/`, `matlab/`, `temp/` dans l’archive nominative. Ouvrir le VI principal dans `temp/Execution/`. Le nom « temp » indique le regroupement de travail : **ne pas supprimer les VIs, preuves, documentation ou transcripts nécessaires au rendu**. Exclure les images d’entrée et les fichiers intermédiaires selon le chapitre 21. L’addendum impose le contenu et l’exécution après extraction, sans imposer ces noms de dossiers.

- [Recette LabVIEW, HTML avec sommaire et copie](temp/docs/recette_labview/Recette_LabVIEW_Binairo.html), [PDF](temp/docs/recette_labview/Recette_LabVIEW_Binairo.pdf), [Markdown](temp/docs/recette_labview/Recette_LabVIEW_Binairo.md).
- [Compiler le C](temp/docs/compilation/Compilation_C.md) ; projet Visual Studio dans `c/OCR.sln`.
- [Techniques et références ME-213/CS-119a](temp/docs/Conformite_programme.md).
- [Vérifications et migration](temp/docs/recette_labview/Verification_donnee.md).
- [Documentation courte, état de préparation](temp/docs/Documentation_projet.md).

Le programme C utilise des dimensions 50..1000 et des seuils entiers 1..99. Valeurs par défaut : 88/90/90. Les sept fonctions MATLAB restent dans `matlab/`. `temp/tests/VerifierMatlab.m` est un contrôle natif à copier dans le dossier d’exécution ; il ne remplace pas le script généré par LabVIEW.

Le binaire `c/bin/macos-arm64/OCR` est compilé et testé sur macOS Apple Silicon. Pour la recette Windows, compiler OCR.exe sur la VM. Les VIs doivent encore être construits et les essais MATLAB/LabVIEW exécutés : **ce dépôt n’est pas encore une archive de remise validée**. Le chapitre 21 explique comment conserver les sorties, réunir les fichiers et retester l’archive téléchargée.
