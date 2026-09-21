/* Projet Binairo - ME-213
 * Auteurs : Louis Pédelaborde, Romeo Mugnier de Almeida, Raphael Raphaël Pical
 * Lecture des arguments et ecriture du resultat OCR.
 */
#include "reconnaissance.h"
#include "parametres_ocr.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char NomSortie[] = "CellValue.txt";

/* Alloue CellValue.txt dans le dossier de l'entree. L'appelant libere le chemin. */
static int ConstruireCheminSortie(const char *entree, char **sortie,
                                  const char **description)
{
    size_t longueur = 0;
    size_t debutNom = 0;
    size_t finNom;
    size_t indice;
    char *nomMinuscules;

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
    /* Ignorer les points et espaces finaux pour controler les noms reserves sous Windows. */
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
    if (strcmp(nomMinuscules, "cellvalue.txt") == 0 ||
        strcmp(nomMinuscules, "cellvalue.txt.tmp") == 0) {
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

/* Refuser d'ecraser un fichier non vide qui n'a pas le format d'un resultat OCR. */
static int VerifierAncienResultat(const char *chemin, const char **description)
{
    FILE *ancien = fopen(chemin, "rb");
    char debut[3];
    size_t lus;
    int etat = OCR_SUCCES;

    if (ancien == NULL) {
        return OCR_SUCCES;
    }
    lus = fread(debut, 1, sizeof debut, ancien);
    if (ferror(ancien) ||
        (lus != 0 && (lus != sizeof debut || debut[0] != 'd' ||
                      debut[1] != ':' || debut[2] != '\''))) {
        etat = OCR_ERREUR_ECRITURE;
        *description = "le fichier de sortie existant n'est pas un resultat OCR";
    }
    if (fclose(ancien) != 0) {
        etat = OCR_ERREUR_ECRITURE;
        *description = "impossible de fermer l'ancien resultat";
    }
    return etat;
}

/* Conserver le format attendu par LabVIEW : symbole, score et fin de ligne. */
static int EcrireResultat(FILE *sortie, const ResultatOCR *resultat,
                          const char **description)
{
    if (fprintf(sortie, "d:'%d', %.6f%%\n", resultat->symbole,
                resultat->pourcentage) < 0 || fflush(sortie) != 0 || ferror(sortie)) {
        *description = "impossible d'ecrire ou de vider le tampon du resultat";
        return OCR_ERREUR_ECRITURE;
    }
    return OCR_SUCCES;
}

int main(int argc, char *argv[])
{
    CelluleOCR cellule = {0, 0, NULL};
    SeuilsOCR seuils = {0.0, 0.0, 0.0};
    ResultatOCR resultat = {-2, 0.0, {0, 0}};
    char *cheminSortie = NULL;
    FILE *sortie = NULL;
    const char *description = "erreur OCR non precisee";
    int etat = OCR_SUCCES;

    if (argc != 5) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "utilisation : OCR <chemin-Cell.bin> <seuil-vide> <seuil-zero> <seuil-un>";
        goto nettoyage;
    }
    etat = ConstruireCheminSortie(argv[1], &cheminSortie, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    if (ConvertirSeuil(argv[2], &seuils.vide) != OCR_SUCCES ||
        ConvertirSeuil(argv[3], &seuils.zero) != OCR_SUCCES ||
        ConvertirSeuil(argv[4], &seuils.un) != OCR_SUCCES) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "les seuils doivent etre des nombres decimaux avec un point, dans [0,100]";
        goto nettoyage;
    }

    etat = LireCellule(argv[1], &cellule, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }

    etat = VerifierAncienResultat(cheminSortie, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }

    /* Un code de retour non nul interdit a LabVIEW d'utiliser le fichier resultat. */
    sortie = fopen(cheminSortie, "wb");
    if (sortie == NULL) {
        etat = OCR_ERREUR_ECRITURE;
        description = "impossible d'ouvrir le fichier de resultat";
        goto nettoyage;
    }
    etat = ReconnaitreCellule(&cellule, &seuils, &resultat, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    etat = EcrireResultat(sortie, &resultat, &description);

/* Meme nettoyage pour une execution normale et pour tous les cas d'erreur. */
nettoyage:
    if (sortie != NULL && fclose(sortie) != 0) {
        etat = OCR_ERREUR_ECRITURE;
        description = "impossible de fermer le fichier de resultat";
    }
    LibererCellule(&cellule);
    free(cheminSortie);
    if (etat != OCR_SUCCES) {
        fprintf(stderr, "OCR E%d: %s\n", etat, description);
    }
    return etat;
}
