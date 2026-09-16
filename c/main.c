/* EPFL ME-213 Binairo 2026. Implementation avec assistance de Codex.
 * Noms des membres de l'equipe a renseigner avant remise. */
#include "reconnaissance.h"
#include "parametres_ocr.h"

#include <stdio.h>
#include <string.h>

/* CellValue.txt est le nom repete dans les documents techniques.
 * Le nom Cell1Value.txt de la page des exemples est une coquille. */
static const char NomSortie[] = "CellValue.txt";

static int ConstruireCheminSortie(const char *entree, char *sortie,
                                  const char **description)
{
    size_t longueur = 0;
    size_t debutNom = 0;
    size_t finNom;
    size_t indice;
    char nomMinuscules[OCR_TAILLE_CHEMIN];

    /* La borne est verifiee avant toute copie dans un tableau fixe. */
    while (longueur < OCR_TAILLE_CHEMIN && entree[longueur] != '\0') {
        ++longueur;
    }
    if (longueur == 0 || longueur == OCR_TAILLE_CHEMIN) {
        *description = "chemin d'entree vide ou trop long (1023 caracteres maximum)";
        return OCR_ERREUR_ARGUMENT;
    }
    /* Accepter les chemins usuels Windows et Unix sans appel au systeme.
     * Les deux barres sont des separateurs ; une barre inverse litterale
     * dans un nom de fichier Unix n'est donc pas prise en charge. */
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
    finNom = longueur;
    /* Windows ignore certains points/espaces terminaux. Les ignorer aussi
     * dans le controle protege les variantes du nom de sortie reserve. */
    while (finNom > debutNom &&
           (entree[finNom - 1] == '.' || entree[finNom - 1] == ' ')) {
        --finNom;
    }
    if (finNom == debutNom) {
        *description = "le chemin d'entree doit designer un fichier";
        return OCR_ERREUR_ARGUMENT;
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
        return OCR_ERREUR_ARGUMENT;
    }
    if (debutNom + sizeof NomSortie > OCR_TAILLE_CHEMIN) {
        *description = "le chemin du resultat serait trop long";
        return OCR_ERREUR_ARGUMENT;
    }
    memcpy(sortie, entree, debutNom);
    memcpy(sortie + debutNom, NomSortie, sizeof NomSortie);
    return OCR_SUCCES;
}

static int VerifierAncienResultat(const char *chemin, const char **description)
{
    FILE *ancien = fopen(chemin, "rb");
    char debut[3];
    size_t lus;
    int etat = OCR_SUCCES;

    if (ancien == NULL) {
        /* Le fichier peut ne pas encore exister. L'ouverture en ecriture
         * verifiera ensuite que sa creation est possible. */
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

static int EcrireResultat(FILE *sortie, const ResultatOCR *resultat,
                          const char **description)
{
    /* Six decimales comme sur Moodle. L'ouverture en mode binaire conserve
     * LF. Le C demarre avec un point decimal, sans configuration de locale. */
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
    char cheminSortie[OCR_TAILLE_CHEMIN];
    FILE *sortie = NULL;
    const char *description = "erreur OCR non precisee";
    int etat = OCR_SUCCES;

    if (argc != 5) {
        etat = OCR_ERREUR_ARGUMENT;
        description = "utilisation : OCR <chemin-Cell.bin> <seuil-vide> <seuil-zero> <seuil-un>";
        goto nettoyage;
    }
    etat = ConstruireCheminSortie(argv[1], cheminSortie, &description);
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
    /* Lire et fermer toute l'entree avant d'ouvrir un fichier en ecriture. */
    etat = LireCellule(argv[1], &cellule, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }

    /* Un resultat non vide doit commencer par d:'. Une cellule binaire
     * valide ne peut pas avoir ce prefixe : ce controle protege notamment
     * l'entree si le nom de sortie designe accidentellement le meme fichier.
     * Utiliser des fichiers ordinaires que personne ne modifie en parallele. */
    etat = VerifierAncienResultat(cheminSortie, &description);
    if (etat != OCR_SUCCES) {
        goto nettoyage;
    }
    /* L'ouverture vide l'ancien resultat avant la reconnaissance. En cas
     * d'erreur anterieure, un ancien resultat peut encore exister : l'appelant
     * ne doit jamais le lire si le code de retour du programme est non nul. */
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

nettoyage:
    if (sortie != NULL && fclose(sortie) != 0) {
        etat = OCR_ERREUR_ECRITURE;
        description = "impossible de fermer le fichier de resultat";
    }
    LibererCellule(&cellule);
    if (etat != OCR_SUCCES) {
        /* Une panne d'ecriture peut laisser un resultat partiel ; le code
         * non nul et stderr interdisent de l'utiliser dans la suite. */
        fprintf(stderr, "OCR E%d: %s\n", etat, description);
    }
    return etat;
}
