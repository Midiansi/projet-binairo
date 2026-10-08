/* Projet Binairo - ME-213
 * Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
 * Bornes des dimensions et des chemins utilises par OCR.
 */
#ifndef BINAIRO_PARAMETRES_OCR_H
#define BINAIRO_PARAMETRES_OCR_H

/* Addendum du projet du 7 octobre 2026, pages physiques 10 et 11. */
#define OCR_DIMENSION_MIN 50u
#define OCR_DIMENSION_MAX 1000u

/* Limite incluant le caractere nul ; les chemins sont alloues avec malloc. */
#define OCR_TAILLE_CHEMIN 1024

#endif
