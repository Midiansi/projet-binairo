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
    int symbole;
    double pourcentage;
    unsigned int maximum[2];
} ResultatOCR;

typedef int16_t short_t;
unsigned char GetDigitBitmapBit(short_t digit, int l, int c);
unsigned char GetCellBit(unsigned char *cell, int Width, int line, int col);

int ConvertirSeuil(const char *texte, double *valeur);
int LireCellule(const char *chemin, CelluleOCR *cellule, const char **description);
void LibererCellule(CelluleOCR *cellule);
int ReconnaitreCellule(const CelluleOCR *cellule, const SeuilsOCR *seuils,
                 ResultatOCR *resultat, const char **description);

#endif
