# Binairo – changements de l’audit du 16 novembre

16 novembre 2026 · Romeo Mugnier de Almeida

**Vous pouvez continuer avec la recette que vous suivez déjà** (`Recette_LabVIEW_Binairo`, version du 11 novembre). Elle n’a pas été modifiée. Cette page liste les seuls points à ajuster ; aucun VI déjà construit n’est à refaire. Le fichier `Changements_LabVIEW` du 11 novembre reste valable et inchangé.

La version corrigée de la recette est un **fichier séparé**, `Recette_LabVIEW_Binairo_audit-16-11` (Markdown, HTML, PDF). Les numéros de chapitres y sont les mêmes ; chaque passage touché porte la mention *(audit 16.11)* et seul le §7.6 est nouveau. Les renvois « § » ci-dessous désignent cette version corrigée.

## Ce qui change

| Quoi | Pourquoi | Action |
| --- | --- | --- |
| `c/reconnaissance.c` : ratio de blancs en simple précision | `CellEmpty.bin` donne maintenant exactement la valeur Moodle `88.166542%` (avant : `88.166545%`) | Recopier le fichier et **recompiler `OCR.exe`** ; aucun VI à modifier |
| `matlab/DisplayBinairo.m` : `print(..., '-dpdf')` sans `-painters` | option ancienne, absente du cours | Recopier le fichier dans Execution |
| §1.1 : projet Visual Studio Release x64, `/MT` | l’addendum exige les fichiers projet du C | Créer le projet sur la VM et le remettre |
| §7.6 : conversion noir/blanc | les traits de `Binairo_6x6_rect.v2.png` sont gris et fins ; la marge est faible | Faire le contrôle G5.6 sur cette image **en premier** ; appliquer le repli seulement si n≠6 |
| §15.3 et §17.1 : commande `Lanceur fourni` | une commande qui ne produit qu’une erreur ne doit pas rester sur la face avant évaluée | La supprimer si l’option n’est pas installée |
| §17.1 : indicateur image d’au moins 870×690 | la plus grande image fournie mesure 862×676 | Agrandir l’indicateur |
| §21.3 : archive à plat | tous les fichiers dans le même dossier, `BinairoSolver.vi` à la racine | Suivre le nouveau §21.3 |
| `temp/Tests` | 49 cas C et un script MATLAB prêts à lancer | §1.1 et §1.2 |

## À faire selon votre avancement

| Si vous en êtes à… | Action |
| --- | --- |
| §1.1, `OCR.exe` déjà compilé | Le recompiler avec le nouveau `reconnaissance.c`, depuis un projet Visual Studio (§1.1 corrigé). **Attention :** l’ancienne recette annonce `d:'-1', 88.166545%` pour `CellEmpty.bin` ; avec le nouveau C, la bonne valeur est `d:'-1', 88.166542%`, celle de Moodle. |
| §1.2, MATLAB déjà testé | Recopier `DisplayBinairo.m`, relancer un essai de PDF. |
| §7 LireImage et annexe G faits | Lancer tout de suite l’essai G5.6 sur `Binairo_6x6_rect.v2.png`. Si n=6 : rien à changer. Sinon : §7.6 de la version corrigée. |
| §7 ou annexe G pas encore faits | Les construire comme prévu, puis faire le même essai avant d’aller plus loin. |
| §15 LancerMatlab ou §17 BinairoSolver faits | Si l’option « lanceur fourni » n’est pas installée, supprimer la commande `Lanceur fourni` et la Case C1 (§15.3) ; agrandir l’indicateur d’image à 870×690 au moins. |
| §15 et §17 pas encore faits | Ne pas créer la commande `Lanceur fourni` ; pour le reste, suivre votre recette. |
| §21 (assemblage du rendu), pour tout le monde | **Ne pas suivre le §21.3 de l’ancienne recette.** Utiliser le §21.3 corrigé : un seul dossier à plat, `BinairoSolver.vi` à la racine, sans les dossiers `c`, `matlab`, `temp`. |

La liste complète de ce qui reste à faire pour le rendu, avec les cases à cocher, est dans `Audit/Checklist_remise_audit-16-11.md`. Le rapport détaillé est dans `Audit/Rapport_audit_2026-11-16.md`.
