# Compact clarification draft

Status: prepared for a teammate to send; **not sent**. Pages below are physical PDF pages, counted from the cover. These questions concern unresolved official details; implementation proceeds with the clearly marked policies in `INTERFACE_CONTRACT.md`.

Bonjour,

Nous avançons sur le projet Binairo 2026 et appliquons les critères généraux d'évaluation de l'an dernier que vous avez confirmés. Pour éviter des incompatibilités avec les tests automatiques, pourriez-vous préciser les points suivants ?

1. **Interface LabVIEW et erreurs** — Un connector pane officiel pour `BinairoSolver.vi`, un VI d'appel automatique et la liste complète des erreurs annoncée p36 de `P00.PPI_Projet.2026.2.pdf` seront-ils fournis ? Nous n'utilisons pas le connector pane du billard 2025.
2. **Sélection OCR** — Faut-il choisir le score de similitude maximal, comme p10 et p3 de l'exercice OCR, ou la différence maximale `score − seuil`, comme p18 du projet ? Nous appliquons provisoirement la seconde règle, avec `score >= seuil` pour les chiffres, `ratio blanc > seuil` pour vide, puis meilleur score brut et enfin 0 en cas d'égalité. Faut-il modifier ces règles ou le traitement « aucune reconnaissance = erreur » ?
3. **Seuils et case vide** — Quels sont les trois seuils officiels et le symbole attendu pour vide dans `CellValue.txt` ? Nous utilisons provisoirement 98/90/90 pour les cellules découpées sans bord, un espace ASCII entre apostrophes pour vide, et quatre décimales pour le pourcentage. Le fichier doit-il être écrit à côté de `Cell.bin` ou dans le répertoire de travail ?
4. **Format et dimensions** — Nous écrivons largeur U32 little-endian, hauteur U32 little-endian, puis les pixels U8 ligne par ligne, conformément aux pp20–22. Pouvez-vous confirmer cet ordre malgré l'exemple d'écriture directe du tableau 2D dans l'exercice LabVIEW ? La plage 10..100 de la p19 est-elle obligatoire ou indicative ? Nous retenons provisoirement 10..256 comme borne de ressources et rejetons tout pixel excédentaire conformément à « pas plus, pas moins ».
5. **Noms et options MATLAB** — Peut-on retenir `solve.m` en minuscules et `DisplayBinairo.m` avec une fonction de compatibilité `DispBinairo.m` ? Pour « Solve with Matlab » désactivé, nous produisons le PDF de la grille initiale ; « Show pdf » commande seulement son ouverture. Est-ce le comportement attendu ?
6. **Critère MATLAB sans boucles** — Pour respecter les critères hérités, nos fonctions évaluées n'ont pas de `for`/`while` explicite : vérifications vectorisées, propagation directe récursive jusqu'à stabilité, puis backtracking récursif avec 0 puis1. Cette mise en œuvre respecte-t-elle votre attente pour 2026 ? Nous suivons bien la règle de taille paire des PDFs malgré « odd » dans le commentaire du squelette fourni.
7. **Rendu 2026** — Pouvez-vous confirmer les noms et le contenu final de l'archive, les fichiers générés attendus, la présence ou non des images fournies, les plateformes exécutables acceptées, le canal/la date de dépôt, et les modalités des PDF de conversations IA ? Nous préparons sources, exécutable testé sur la plateforme indiquée, VIs, scripts, résultats, rapport court et transcriptions disponibles, sans considérer les anciens noms de fichiers du billard comme applicables.

Merci !
