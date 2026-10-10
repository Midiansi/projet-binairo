/* Projet Binairo - ME-213
 * Auteurs : Louis Pedelaborde, Romeo Mugnier de Almeida, Raphael Pical
 * Lecture des arguments et ecriture du resultat OCR.
 */
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include "reconnaissance.h"
#include "parametres_ocr.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int ConstruireCheminSortie(const char *entree, char **sortie, const char **description);
int EcrireResultat(FILE *sortie, const ResultatOCR *resultat, const char **description);

static const char NomSortie[] = "CellValue.txt";

/**
 * ConstruireCheminSortie - Former le chemin de CellValue.txt sans confondre entree et sortie.
 * Entrees : entree : chemin non vide, au plus 1023 caracteres.
 * Sorties : sortie : chemin alloue a liberer, ou NULL en cas d'erreur ; description : message en cas d'erreur.
 * Retour : OCR_SUCCES, OCR_ERREUR_ARGUMENT ou OCR_ERREUR_LECTURE.
 */
int ConstruireCheminSortie(const char *entree, char **sortie,
                                  const char **description)
{
    size_t longueur = 0;
    size_t debutNom = 0;
    size_t finNom;
    size_t indice;
    char *nomMinuscules;

    *sortie = NULL;

    while (longueur < OCR_TAILLE_CHEMIN && entree[longueur] != '\0') {
        ++longueur;
    }
    if (longueur == 0 || longueur == OCR_TAILLE_CHEMIN) {
        *description = "chemin d'entree vide ou trop long (1023 caracteres maximum)";
        return OCR_ERREUR_ARGUMENT;
    }

    if (longueur >= 2 && entree[1] == ':' &&
        ((entree[0] >= 'A' && entree[0] <= 'Z') ||
         (entree[0] >= 'a' && entree[0] <= 'z'))) {
        debutNom = 2;
    }
    for (indice = 0; indice < longueur; ++indice) {
        if (entree[indice] == '/' || entree[indice] == '\\') {
            debutNom = indice + 1;
        }
        if (entree[indice] == ':' &&
            (indice != 1 || !((entree[0] >= 'A' && entree[0] <= 'Z') ||
                              (entree[0] >= 'a' && entree[0] <= 'z')))) {
            *description = "deux-points autorise uniquement apres une lettre de lecteur";
            return OCR_ERREUR_ARGUMENT;
        }
    }
    /* Eviter que le fichier d'entree designe aussi CellValue.txt sous Windows. */
    finNom = longueur;

    while (finNom > debutNom &&
           (entree[finNom - 1] == '.' || entree[finNom - 1] == ' ')) {
        --finNom;
    }
    if (finNom == debutNom) {
        *description = "le chemin d'entree doit designer un fichier";
        return OCR_ERREUR_ARGUMENT;
    }
    nomMinuscules = malloc(finNom - debutNom + 1);
    if (nomMinuscules == NULL) {
        *description = "impossible d'allouer le nom du fichier";
        return OCR_ERREUR_LECTURE;
    }
    for (indice = debutNom; indice < finNom; ++indice) {
        char caractere = entree[indice];
        if (caractere >= 'A' && caractere <= 'Z') {
            caractere = (char)(caractere - 'A' + 'a');
        }
        nomMinuscules[indice - debutNom] = caractere;
    }
    nomMinuscules[finNom - debutNom] = '\0';
    if (strcmp(nomMinuscules, "cellvalue.txt") == 0) {
        *description = "le nom d'entree est reserve a une sortie OCR";
        free(nomMinuscules);
        return OCR_ERREUR_ARGUMENT;
    }
    free(nomMinuscules);
    if (debutNom + sizeof NomSortie > OCR_TAILLE_CHEMIN) {
        *description = "le chemin du resultat serait trop long";
        return OCR_ERREUR_ARGUMENT;
    }
    *sortie = malloc(debutNom + sizeof NomSortie);
    if (*sortie == NULL) {
        *description = "impossible d'allouer le chemin du resultat";
        return OCR_ERREUR_LECTURE;
    }
    memcpy(*sortie, entree, debutNom);
    memcpy(*sortie + debutNom, NomSortie, sizeof NomSortie);
    return OCR_SUCCES;
}

/**
 * EcrireResultat - Ecrire le symbole, le pourcentage et la fin de ligne attendus par LabVIEW.
 * Entrees : sortie : fichier ouvert ; resultat : reconnaissance obtenue.
 * Sorties : Fichier ecrit ; description : message en cas d'erreur.
 * Retour : OCR_SUCCES ou OCR_ERREUR_ECRITURE.
 */
int EcrireResultat(FILE *sortie, const ResultatOCR *resultat,
                          const char **description)
{
    if (fprintf(sortie, "d:'%d', %.6f%%\n", resultat->symbole,
                resultat->pourcentage) < 0 || fflush(sortie) != 0 || ferror(sortie)) {
        *description = "impossible d'ecrire ou de vider le tampon du resultat";
        return OCR_ERREUR_ECRITURE;
    }
    return OCR_SUCCES;
}

/**
 * main - Lire une cellule, reconnaitre son contenu et ecrire CellValue.txt.
 * Entrees : argc, argv : programme, chemin de cellule et trois seuils.
 * Sorties : CellValue.txt ; message sur stderr en cas d'erreur.
 * Retour : Code EtatOCR ; zero indique une execution reussie.
 */
int main(int argc, char *argv[])
{
    CelluleOCR cellule = {0, 0, NULL};
    SeuilsOCR seuils = {0.0, 0.0, 0.0};
    ResultatOCR resultat = {-2, 0.0, {0, 0}};
    char *cheminSortie = NULL;
    char *cheminEntree = NULL;
    size_t longueurChemin;
    FILE *sortie = NULL;
    const char *description = "erreur OCR non precisee";
    int etat = OCR_SUCCES;

    if (argc != 5) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "utilisation : OCR <chemin-Cell.bin> <seuil-vide> <seuil-zero> <seuil-un>";
        goto nettoyage;
    }
    cheminEntree = argv[1];
    longueurChemin = strlen(cheminEntree);
    if (longueurChemin >= 2 &&
        ((cheminEntree[0] == '\'' && cheminEntree[longueurChemin - 1] == '\'') ||
         (cheminEntree[0] == '"' && cheminEntree[longueurChemin - 1] == '"'))) {
        cheminEntree[longueurChemin - 1] = '\0';
        ++cheminEntree;
    }
    etat = ConstruireCheminSortie(cheminEntree, &cheminSortie, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    if (ConvertirSeuil(argv[2], &seuils.vide) != OCR_SUCCES ||
        ConvertirSeuil(argv[3], &seuils.zero) != OCR_SUCCES ||
        ConvertirSeuil(argv[4], &seuils.un) != OCR_SUCCES) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "les seuils doivent etre des entiers de 1 a 99 inclus (sans point decimal)";
        goto nettoyage;
    }

    etat = LireCellule(cheminEntree, &cellule, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }

    etat = ReconnaitreCellule(&cellule, &seuils, &resultat, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }

    /* Un code de retour non nul interdit a LabVIEW d'utiliser le fichier resultat. */
    sortie = fopen(cheminSortie, "w");
    if (sortie == NULL) {
        etat = OCR_ERREUR_ECRITURE;
        description = "impossible d'ouvrir le fichier de resultat";
        goto nettoyage;
    }
    etat = EcrireResultat(sortie, &resultat, &description);

/* Meme nettoyage pour une execution normale et pour tous les cas d'erreur. */
nettoyage:
    /* fclose vide aussi le tampon : verifier son retour detecte une ecriture differee en echec. */
    if (sortie != NULL && fclose(sortie) != 0) {
        etat = OCR_ERREUR_ECRITURE;
        description = "impossible de fermer le fichier de resultat";
    }
    /* Vider un ancien resultat si possible, sans remplacer l'erreur initiale. */
    if (etat != OCR_SUCCES && cheminSortie != NULL) {
        sortie = fopen(cheminSortie, "w");
        if (sortie != NULL) {
            fclose(sortie);
        }
    }
    LibererCellule(&cellule);
    free(cheminSortie);
    if (etat != OCR_SUCCES) {
        fprintf(stderr, "OCR E%d: %s\n", etat, description);
    }
    return etat;
}
