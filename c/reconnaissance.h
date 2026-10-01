/* Projet Binairo - ME-213
 * Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
 * Types, codes de retour et fonctions de reconnaissance.
 */
#ifndef BINAIRO_RECONNAISSANCE_H
#define BINAIRO_RECONNAISSANCE_H

#include <stddef.h>
#include <stdint.h>

/* Tout code non nul signale un echec ; le message correspondant est ecrit sur stderr. */
enum EtatOCR {
    OCR_SUCCES = 0,
    OCR_ERREUR_ARGUMENT = 2, /* Nombre d'arguments, chemin ou seuil invalide. */
    OCR_ERREUR_FORMAT = 3,   /* Entete, dimensions, nombre ou valeur des pixels. */
    OCR_ERREUR_LECTURE = 4,  /* Ouverture/lecture de l'entree ou allocation impossible. */
    OCR_AUCUN_CHIFFRE = 5,   /* Case non vide : aucun modele admissible. */
    OCR_ERREUR_ECRITURE = 6  /* Ouverture, ecriture ou fermeture de la sortie. */
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
/* pixels doit etre NULL avant la lecture. LibererCellule libere le tableau et le remet a NULL. */
int LireCellule(const char *chemin, CelluleOCR *cellule, const char **description);
void LibererCellule(CelluleOCR *cellule);
int ReconnaitreCellule(const CelluleOCR *cellule, const SeuilsOCR *seuils,
                 ResultatOCR *resultat, const char **description);

#endif
