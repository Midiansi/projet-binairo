/* Projet Binairo - ME-213
 * Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
 * Lecture des pixels et reconnaissance des chiffres 0 et 1.
 */
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include "reconnaissance.h"
#include "parametres_ocr.h"

#include <stdio.h>
#include <stdlib.h>

#include "FontRasterized_0_1.h"

int EstChiffreDecimal(char caractere);
uint32_t LireEntier32PetitBoutiste(const unsigned char *octets);
int ChoisirChiffre(const double scores[2], const double seuils[2]);

/**
 * GetDigitBitmapBit - Lire un pixel du modele ; le pixel gauche est le bit 31.
 * Entrees : digit : 0 ou 1 ; l, c : indices valides du modele.
 * Sorties : Aucune.
 * Retour : Pixel : 0 blanc, 1 noir.
 */
unsigned char GetDigitBitmapBit(short_t digit, int l, int c)
{
    const uint32_t bits = (uint32_t)DigitBitmap[digit][l];
    return (unsigned char)((bits >> (31u - (unsigned int)c)) & 1u);
}

/**
 * GetCellBit - Lire un pixel dans le tableau range ligne par ligne.
 * Entrees : cell : pixels ; Width : largeur ; line, col : indices valides.
 * Sorties : Aucune.
 * Retour : Pixel : 0 blanc, 1 noir.
 */
unsigned char GetCellBit(unsigned char *cell, int Width, int line, int col)
{
    return cell[(size_t)line * (size_t)Width + (size_t)col];
}

/**
 * EstChiffreDecimal - Tester si un caractere est un chiffre decimal.
 * Entrees : caractere : caractere a tester.
 * Sorties : Aucune.
 * Retour : 1 pour un chiffre de 0 a 9, sinon 0.
 */
int EstChiffreDecimal(char caractere)
{
    return caractere >= '0' && caractere <= '9';
}

/**
 * ConvertirSeuil - Lire un entier decimal compris entre 1 et 99 inclus.
 * Entrees : texte : chiffres, precedes eventuellement de + ; valeur : adresse du resultat.
 * Sorties : valeur : seuil converti, ou 0 en cas d'erreur si le pointeur est valide.
 * Retour : OCR_SUCCES ou OCR_ERREUR_ARGUMENT.
 */
int ConvertirSeuil(const char *texte, double *valeur)
{
    const char *curseur;
    unsigned int entier = 0;

    if (valeur != NULL) {
        *valeur = 0.0;
    }
    if (texte == NULL || valeur == NULL || *texte == '\0') {
        return OCR_ERREUR_ARGUMENT;
    }
    curseur = texte;
    if (*curseur == '+') {
        ++curseur;
    }
    if (*curseur == '\0') {
        return OCR_ERREUR_ARGUMENT;
    }
    while (*curseur != '\0') {
        if (!EstChiffreDecimal(*curseur)) {
            return OCR_ERREUR_ARGUMENT;
        }
        /* Verifier a chaque chiffre garde aussi le calcul dans un petit entier. */
        entier = 10u * entier + (unsigned int)(*curseur - '0');
        if (entier > 99u) {
            return OCR_ERREUR_ARGUMENT;
        }
        ++curseur;
    }
    if (entier < 1u) {
        return OCR_ERREUR_ARGUMENT;
    }
    *valeur = (double)entier;
    return OCR_SUCCES;
}

/**
 * LireEntier32PetitBoutiste - Decoder quatre octets en ordre petit-boutiste.
 * Entrees : octets : adresse de quatre octets accessibles.
 * Sorties : Aucune.
 * Retour : Entier non signe sur 32 bits.
 */
uint32_t LireEntier32PetitBoutiste(const unsigned char *octets)
{
    return (uint32_t)octets[0] |
           ((uint32_t)octets[1] << 8u) |
           ((uint32_t)octets[2] << 16u) |
           ((uint32_t)octets[3] << 24u);
}

/**
 * LibererCellule - Liberer les pixels et remettre la cellule a zero.
 * Entrees : cellule : adresse de la cellule, ou NULL.
 * Sorties : pixels remis a NULL ; largeur et hauteur remises a zero.
 * Retour : Aucun.
 */
void LibererCellule(CelluleOCR *cellule)
{
    if (cellule != NULL) {
        free(cellule->pixels);
        cellule->pixels = NULL;
        cellule->largeur = 0;
        cellule->hauteur = 0;
    }
}

/**
 * LireCellule - Lire et verifier les dimensions et les pixels du fichier binaire.
 * Entrees : chemin : fichier ; cellule : structure dont pixels vaut NULL.
 * Sorties : cellule : dimensions et pixels alloues ; description : message d'erreur.
 * Retour : OCR_SUCCES ou code d'erreur de lecture ou de format.
 */
int LireCellule(const char *chemin, CelluleOCR *cellule, const char **description)
{
    FILE *entree = NULL;
    unsigned char entete[8];
    size_t nombrePixels = 0;
    size_t indice;
    int etat = OCR_SUCCES;
    int suivant;

    cellule->largeur = 0;
    cellule->hauteur = 0;
    entree = fopen(chemin, "rb");
    if (entree == NULL) {
        *description = "impossible d'ouvrir le fichier de cellule";
        return OCR_ERREUR_LECTURE;
    }
    if (fread(entete, 1, sizeof entete, entree) != sizeof entete) {
        etat = ferror(entree) ? OCR_ERREUR_LECTURE : OCR_ERREUR_FORMAT;
        *description = ferror(entree) ? "echec de lecture de l'entete" :
                                      "l'entete doit contenir 8 octets";
        goto nettoyage;
    }
    cellule->largeur = LireEntier32PetitBoutiste(entete);
    cellule->hauteur = LireEntier32PetitBoutiste(entete + 4);
    if (cellule->largeur < OCR_DIMENSION_MIN || cellule->largeur > OCR_DIMENSION_MAX ||
        cellule->hauteur < OCR_DIMENSION_MIN || cellule->hauteur > OCR_DIMENSION_MAX) {
        etat = OCR_ERREUR_FORMAT;
        *description = "dimensions de cellule hors des bornes configurees";
        goto nettoyage;
    }

    /* Une cellule peut etre rectangulaire. Les deux dimensions sont validees
     * avant le produit : au plus 1000 * 1000 octets, lus en une fois. */
    nombrePixels = (size_t)cellule->largeur * (size_t)cellule->hauteur;
    cellule->pixels = malloc(nombrePixels);
    if (cellule->pixels == NULL) {
        etat = OCR_ERREUR_LECTURE;
        *description = "impossible d'allouer le tableau de pixels";
        goto nettoyage;
    }

    if (fread(cellule->pixels, 1, nombrePixels, entree) != nombrePixels) {
        etat = ferror(entree) ? OCR_ERREUR_LECTURE : OCR_ERREUR_FORMAT;
        *description = ferror(entree) ? "echec de lecture des pixels" :
                                      "nombre de pixels inferieur au produit largeur fois hauteur";
        goto nettoyage;
    }
    suivant = fgetc(entree);
    if (ferror(entree)) {
        etat = OCR_ERREUR_LECTURE;
        *description = "echec de lecture en fin de fichier";
        goto nettoyage;
    }
    if (suivant != EOF) {
        etat = OCR_ERREUR_FORMAT;
        *description = "nombre de pixels superieur au produit largeur fois hauteur";
        goto nettoyage;
    }
    for (indice = 0; indice < nombrePixels; ++indice) {
        if (cellule->pixels[indice] > 1u) {
            etat = OCR_ERREUR_FORMAT;
            *description = "chaque pixel doit etre un octet 0 (blanc) ou 1 (noir)";
            goto nettoyage;
        }
    }

nettoyage:
    if (fclose(entree) != 0 && etat == OCR_SUCCES) {
        etat = OCR_ERREUR_LECTURE;
        *description = "impossible de fermer le fichier de cellule";
    }
    if (etat != OCR_SUCCES) {
        LibererCellule(cellule);
    }
    return etat;
}

/**
 * ChoisirChiffre - Choisir la plus grande marge score-seuil ; garder 0 a egalite.
 * Entrees : scores, seuils : tableaux de deux valeurs, pour 0 puis 1.
 * Sorties : Aucune.
 * Retour : Chiffre choisi, ou -1 si aucun seuil n'est atteint.
 */
int ChoisirChiffre(const double scores[2], const double seuils[2])
{
    int choisi = -1;
    unsigned int chiffre;
    for (chiffre = 0; chiffre < 2u; ++chiffre) {
        if (scores[chiffre] >= seuils[chiffre] &&
            (choisi < 0 || scores[chiffre] - seuils[chiffre] >
                           scores[choisi] - seuils[choisi])) {
            choisi = (int)chiffre;
        }
    }
    return choisi;
}

/**
 * ReconnaitreCellule - Tester le vide puis comparer la cellule aux deux modeles de chiffres.
 * Entrees : cellule : pixels valides ; seuils : entiers de 1 a 99, stockes en double.
 * Sorties : resultat : symbole et score (ratio de blancs pour -2) ; description : message en cas d'echec.
 * Retour : OCR_SUCCES ou OCR_AUCUN_CHIFFRE.
 */
int ReconnaitreCellule(const CelluleOCR *cellule, const SeuilsOCR *seuils,
                 ResultatOCR *resultat, const char **description)
{
    size_t blancs = 0;
    const size_t nombrePixels = (size_t)cellule->largeur * (size_t)cellule->hauteur;
    size_t indice;
    unsigned int chiffre;
    double scores[2];
    const double seuilsChiffres[2] = {seuils->zero, seuils->un};
    int choisi;

    resultat->symbole = -2;
    resultat->pourcentage = 0.0;
    resultat->maximum[0] = 0;
    resultat->maximum[1] = 0;
    for (indice = 0; indice < nombrePixels; ++indice) {
        blancs += cellule->pixels[indice] == 0u;
    }

    /* Tester la case vide avant les chiffres ; ecrire -2 et le ratio de blancs. */
    if (100.0 * (double)blancs / (double)nombrePixels > seuils->vide) {
        resultat->pourcentage = 100.0 * (double)blancs / (double)nombrePixels;
        return OCR_SUCCES;
    }
    if (cellule->largeur < DigitBitmapWidth || cellule->hauteur < DigitBitmapHeight) {
        *description = "cellule non vide trop petite pour les modeles de 32 par 32 pixels";
        return OCR_AUCUN_CHIFFRE;
    }

    for (chiffre = 0; chiffre < 2u; ++chiffre) {
        size_t y;
        for (y = 0; y <= (size_t)cellule->hauteur - DigitBitmapHeight; ++y) {
            size_t x;
            for (x = 0; x <= (size_t)cellule->largeur - DigitBitmapWidth; ++x) {
                unsigned int identiques = 0;
                size_t ligne;
                for (ligne = 0; ligne < DigitBitmapHeight; ++ligne) {
                    size_t colonne;
                    for (colonne = 0; colonne < DigitBitmapWidth; ++colonne) {
                        /* Compter les egalites de pixels blancs aussi bien que noirs. */
                        identiques += GetCellBit(cellule->pixels, (int)cellule->largeur,
                                                (int)(y + ligne), (int)(x + colonne)) ==
                                 GetDigitBitmapBit((short_t)chiffre, (int)ligne, (int)colonne);
                    }
                }
                if (identiques > resultat->maximum[chiffre]) {
                    resultat->maximum[chiffre] = identiques;
                }
            }
        }
        scores[chiffre] = 100.0 * (double)resultat->maximum[chiffre] / (DigitBitmapWidth * DigitBitmapHeight);
    }
    choisi = ChoisirChiffre(scores, seuilsChiffres);
    if (choisi < 0) {
        *description = "aucun chiffre n'atteint son seuil de reconnaissance";
        return OCR_AUCUN_CHIFFRE;
    }
    resultat->symbole = choisi;
    resultat->pourcentage = scores[choisi];
    return OCR_SUCCES;
}
