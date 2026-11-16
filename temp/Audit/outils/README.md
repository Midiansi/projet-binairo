# Outils de l’audit (hors projet, hors rendu)

Scripts Python utilisés le 16 novembre 2026 pour vérifier le projet sans MATLAB ni LabVIEW. Ils ne font pas partie du programme et ne doivent pas être remis.

| Script | Rôle |
| --- | --- |
| `generer_cellules_test.py <dossier> <FontRasterized_0_1.h>` | fabrique les fichiers de `temp/Tests/cellules` |
| `simuler_chaine_labview.py <dossier des PNG> <OCR> <dossier de travail>` | reproduit hors LabVIEW la conversion noir/blanc, le comptage des traits et la découpe de la recette, puis lance le vrai exécutable OCR sur chaque case |
| `transcription_solveur.py` | transcription ligne à ligne de `SolveBinairo.m` et de `GrilleBinairoValide.m`, comparée aux solutions du professeur et à un solveur par énumération |
