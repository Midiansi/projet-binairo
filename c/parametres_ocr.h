/* EPFL ME-213 Binairo 2026.
 * Noms des membres de l'equipe a renseigner avant remise. */
#ifndef BINAIRO_PARAMETRES_OCR_H
#define BINAIRO_PARAMETRES_OCR_H

/* Bornes choisies selon l'exemple de P00.PPI_Projet.2026.2.pdf, p. 19.
 * Ce document les presente comme un exemple, pas comme une obligation. */
#define OCR_DIMENSION_MIN 10u
#define OCR_DIMENSION_MAX 100u

/* Limite de taille des chemins, caractere final nul compris.
 * Tout chemin ou chemin de sortie plus long est refuse avant copie. */
#define OCR_TAILLE_CHEMIN 1024

#endif
