/* EPFL ME-213 Binairo 2026. Implementation avec assistance de Codex.
 * Noms des membres de l'equipe a renseigner avant remise. */
#ifndef BINAIRO_RECONNAISSANCE_H
#define BINAIRO_RECONNAISSANCE_H

#include <stddef.h>
#include <stdint.h>

enum EtatOCR {
    OCR_SUCCES = 0,
    OCR_ERREUR_ARGUMENT = 2,
    OCR_ERREUR_FORMAT = 3,
    OCR_ERREUR_LECTURE = 4,
    OCR_AUCUN_CHIFFRE = 5,
    OCR_ERREUR_ECRITURE = 6
};

typedef struct {
    uint32_t largeur;
    uint32_t hauteur;
    unsigned char *pixels;
} CelluleOCR;

typedef struct {
    double vide;
    double zero;
    double un;
} SeuilsOCR;

typedef struct {
    int symbole; /* 0, 1 ou -2 pour une case vide, comme sur Moodle. */
    double pourcentage;
    unsigned int maximum[2];
} ResultatOCR;

/* Noms et parametres des exemples du professeur (exercice OCR, p. 2).
 * Les indices commencent a zero ; les appelants verifient les bornes.
 * short_t est defini ici car ce nom du document ne fait pas partie du C. */
typedef int16_t short_t;
unsigned char GetDigitBitmapBit(short_t digit, int l, int c);
unsigned char GetCellBit(unsigned char *cell, int Width, int line, int col);

/* LireCellule exige pixels == NULL. LibererCellule libere puis remet a zero.
 * Les erreurs renvoient un EtatOCR et une description statique. */
int ConvertirSeuil(const char *texte, double *valeur);
int LireCellule(const char *chemin, CelluleOCR *cellule, const char **description);
void LibererCellule(CelluleOCR *cellule);
int ReconnaitreCellule(const CelluleOCR *cellule, const SeuilsOCR *seuils,
                 ResultatOCR *resultat, const char **description);

#endif
