/* EPFL ME-213 Binairo 2026. Implementation avec assistance de Codex.
 * Noms des membres de l'equipe a renseigner avant remise. */
#include "reconnaissance.h"

#include <errno.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Ces appels suppriment uniquement des fichiers, jamais un repertoire. */
#ifdef _WIN32
#include <io.h>
#define SupprimerFichierSeul _unlink
#else
#include <unistd.h>
#define SupprimerFichierSeul unlink
#endif

/* CellValue.txt est le nom repete dans les documents techniques.
 * Le nom Cell1Value.txt de la page des exemples est une coquille. */
static const char NomSortie[] = "CellValue.txt";
static const char NomTemporaire[] = "CellValue.txt.tmp";

static int EstSeparateur(char caractere)
{
#ifdef _WIN32
    return caractere == '/' || caractere == '\\';
#else
    return caractere == '/';
#endif
}

static int ConstruireCheminsSortie(const char *entree, char **sortie, char **temporaire,
                       const char **description)
{
    const char *nomBase = entree;
    const char *curseur;
    size_t longueurPrefixe;
    if (*entree == '\0') {
        *description = "le chemin d'entree ne doit pas etre vide";
        return OCR_ERREUR_ARGUMENT;
    }
#ifdef _WIN32
    if (((entree[0] >= 'A' && entree[0] <= 'Z') ||
         (entree[0] >= 'a' && entree[0] <= 'z')) && entree[1] == ':') {
        nomBase = entree + 2;
    }
#endif
    for (curseur = entree; *curseur != '\0'; ++curseur) {
        if (EstSeparateur(*curseur)) {
            nomBase = curseur + 1;
        }
    }
    if (*nomBase == '\0' || strcmp(nomBase, ".") == 0 || strcmp(nomBase, "..") == 0) {
        *description = "le chemin d'entree doit designer un fichier";
        return OCR_ERREUR_ARGUMENT;
    }

    {
        char minuscules[sizeof NomTemporaire];
        const size_t longueur = strlen(nomBase);
        if (longueur < sizeof minuscules) {
            size_t indice;
            for (indice = 0; indice <= longueur; ++indice) {
                const char caractere = nomBase[indice];
                minuscules[indice] = (caractere >= 'A' && caractere <= 'Z') ?
                                (char)(caractere - 'A' + 'a') : caractere;
            }
            if (strcmp(minuscules, "cellvalue.txt") == 0 ||
                strcmp(minuscules, "cellvalue.txt.tmp") == 0) {
                *description = "le nom d'entree est reserve a une sortie OCR";
                return OCR_ERREUR_ARGUMENT;
            }
        }
    }
    longueurPrefixe = (size_t)(nomBase - entree);
    if (longueurPrefixe > SIZE_MAX - sizeof NomTemporaire) {
        *description = "le chemin d'entree est trop long";
        return OCR_ERREUR_ARGUMENT;
    }
    *sortie = malloc(longueurPrefixe + sizeof NomSortie);
    *temporaire = malloc(longueurPrefixe + sizeof NomTemporaire);
    if (*sortie == NULL || *temporaire == NULL) {
        *description = "impossible d'allouer les chemins de sortie";
        return OCR_ERREUR_LECTURE;
    }
    memcpy(*sortie, entree, longueurPrefixe);
    memcpy(*sortie + longueurPrefixe, NomSortie, sizeof NomSortie);
    memcpy(*temporaire, entree, longueurPrefixe);
    memcpy(*temporaire + longueurPrefixe, NomTemporaire, sizeof NomTemporaire);
    return OCR_SUCCES;
}

static int SupprimerAncienFichier(const char *chemin, const char **description)
{
    if (SupprimerFichierSeul(chemin) != 0 && errno != ENOENT) {
        *description = "impossible de supprimer l'ancienne sortie OCR ou son fichier temporaire";
        return OCR_ERREUR_ECRITURE;
    }
    return OCR_SUCCES;
}

static int EcrireResultat(const char *sortie, const char *temporaire,
                       const ResultatOCR *resultat, const char **description)
{
    FILE *flux = fopen(temporaire, "wb");
    int etat = OCR_SUCCES;
    if (flux == NULL) {
        *description = "impossible de creer le fichier temporaire de sortie";
        return OCR_ERREUR_ECRITURE;
    }

    /* Six decimales comme sur Moodle ; point decimal et fin de ligne LF. */
    if (fprintf(flux, "d:'%d', %.6f%%\n", resultat->symbole,
                resultat->pourcentage) < 0 || fflush(flux) != 0 || ferror(flux)) {
        *description = "impossible d'ecrire ou de vider le tampon du fichier temporaire";
        etat = OCR_ERREUR_ECRITURE;
    }
    if (fclose(flux) != 0 && etat == OCR_SUCCES) {
        *description = "impossible de fermer le fichier temporaire";
        etat = OCR_ERREUR_ECRITURE;
    }
    if (etat == OCR_SUCCES && rename(temporaire, sortie) != 0) {
        *description = "impossible de mettre en place le fichier de resultat";
        etat = OCR_ERREUR_ECRITURE;
    }
    if (etat != OCR_SUCCES) {

        (void)SupprimerFichierSeul(temporaire);
    }
    return etat;
}

int main(int argc, char *argv[])
{
    CelluleOCR cellule = {0, 0, NULL};
    SeuilsOCR seuils = {0.0, 0.0, 0.0};
    ResultatOCR resultat = {-2, 0.0, {0, 0}};
    char *sortie = NULL;
    char *temporaire = NULL;
    const char *description = "erreur OCR non precisee";
    int etat = OCR_SUCCES;

    (void)setlocale(LC_NUMERIC, "C");
    if (argc < 2) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "utilisation : OCR <chemin-Cell.bin> <seuil-vide> <seuil-zero> <seuil-un>";
        goto nettoyage;
    }
    etat = ConstruireCheminsSortie(argv[1], &sortie, &temporaire, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }

    /* Invalider tout resultat ancien avant de traiter la nouvelle cellule. */
    etat = SupprimerAncienFichier(sortie, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    etat = SupprimerAncienFichier(temporaire, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    if (argc != 5) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "quatre arguments attendus : chemin d'entree et trois seuils";
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
    etat = ReconnaitreCellule(&cellule, &seuils, &resultat, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    etat = EcrireResultat(sortie, temporaire, &resultat, &description);

nettoyage:
    LibererCellule(&cellule);
    free(sortie);
    free(temporaire);
    if (etat != OCR_SUCCES) {
        (void)fprintf(stderr, "OCR E%d: %s\n", etat, description);
    }
    return etat;
}
