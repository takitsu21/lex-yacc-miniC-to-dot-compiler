
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table.h"
#include "symboles.h"

extern int yylineno;
extern int scope;
extern int yycol;
int hash(char *nom)
{
    int i, r;
    int taille = strlen(nom);
    r = 0;
    for (i = 0; i < taille; i++)
        r = ((r << 8) + nom[i]) % TAILLE;
    return r;
}

void table_reset(symbole_t **table)
{
    int i;
    for (i = 0; i < TAILLE; i++)
        table[i] = NULL;
}

symbole_t *inserer(symbole_t **table, char *nom)
{
    int h;
    symbole_t *s;
    symbole_t *precedent;

    h = hash(nom);
    s = table[h];
    precedent = NULL;

    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0)
        {
            printf("Symbole %s deja déclaré\n", s->nom);
            return s;
        }
        precedent = s;
        s = s->suivant;
    }
    if (precedent == NULL)
    {
        table[h] = (symbole_t *)malloc(sizeof(symbole_t));
        s = table[h];
    }
    else
    {
        precedent->suivant = (symbole_t *)malloc(sizeof(symbole_t));
        s = precedent->suivant;
    }

    s->nom = strdup(nom);
    s->suivant = NULL;
    s->scope = scope;
    return s;
}

symbole_t *create_symb(const char *nom, void *type)
{
    symbole_t *s = (symbole_t *)malloc(sizeof(symbole_t));
    s->nom = strdup(nom);
    s->type = (type_t)type;
    s->scope = scope;
    return s;
}

void insert_next_symb(symbole_t *symb1, symbole_t *symb2)
{
    symbole_t *head = symb1;
    while (head->suivant != NULL)
    {
        head = head->suivant;
    }
    head->suivant = symb2;
}

void affiche(symbole_t **table)
{
    int i = 0;
    symbole_t *s;
    for (i = 0; i < TAILLE; i++)
    {
        if (table[i] == NULL)
        {
            printf(" orpo table[%d]->NULL\n", i);
        }
        else
        {
            s = table[i];
            printf("table[%d] scope : %d -> %s ", i, s->scope, s->nom);
            while (s->suivant != NULL)
            {
                printf("[%s] scope : %d ->", s->nom, s->scope);
                s = s->suivant;
            }
            printf("NULL\n");
        }
    }
}

record_t *add_record(const char *nom, type_t type)
{
    record_t *record = (record_t *)malloc(sizeof(record_t));
    record->nom = nom;
    record->type = type;
    record->decLineNo = yylineno;
    return record;
}

liste_t *creer_liste(param_t *p)
{
    liste_t *liste;
    liste = (liste_t *)malloc(sizeof(liste_t));
    liste->param = p;
    liste->suivant = NULL;
    return liste;
}

liste_t *concatener_listes(liste_t *l1, liste_t *l2)
{
    liste_t *l = l1;
    if (l1 == NULL)
        return l2;
    while (l->suivant != NULL)
        l = l->suivant;
    l->suivant = l2;
    return l1;
}

void semantic_error(const char *error)
{
    fprintf(stderr, "Semantic error at line %d:%d : %s\n", yylineno, yycol, error);
    exit(1);
}

fonction_t *ajouter_fonction(type_t type, const char *nom, liste_t *args, symbole_t *declarations)
{
    int h;
    fonction_t *f;
    fonction_t *precedent;
    fonction_t *nouvelle_fonction;
    h = hash(nom);
    f = fonctions[h];
    precedent = NULL;
    while (f != NULL)
    {
        if (strcmp(f->nom, nom) == 0)
        {
            /* on a trouvé une fonction portant le meme nom */
            if ((f->type == type) && (listes_egales(f->arguments, args)))
                printf("Re-déclaration cohérente de la fonction %s a la ligne %d:%d\n", f->nom, yylineno, yycol);
            else
                printf("Re-déclaration incohérente de la fonction %s a la ligne %d:%d\n", f->nom, yylineno, yycol);
                exit(1);
            return NULL;
        }
        precedent = f;
        f = f->suivant;
    }
    nouvelle_fonction = (fonction_t *)malloc(sizeof(fonction_t));

    if (precedent == NULL)
    {
        fonctions[h] = nouvelle_fonction;
        f = fonctions[h];
    }
    else
    {
        precedent->suivant = nouvelle_fonction;
        f = precedent->suivant;
    }
    f->type = type;
    f->nom = strdup(nom);
    f->arguments = args;
    f->declarations = declarations;
    f->suivant = NULL;
    return f;
}
int listes_egales(liste_t *l1, liste_t *l2)
{
    liste_t *liste;
    for (liste = l1; liste != NULL; liste = liste->suivant)
    {
        if ((l2 == NULL) || (l2->param->type != liste->param->type))
            return 0;
        l2 = l2->suivant;
    }
    if (l2 != NULL)
        return 0;
    return 1;
}

void afficher_liste(liste_t *liste)
{
    liste_t *next = liste;
    while (next != NULL) {
        printf(" %s (%s)", next->param->nom,
               get_type(next->param->type));
        next = next->suivant;
    }
}

void afficher_symb(symbole_t *declarations) {
    symbole_t *next = declarations;
    printf("Declarations : ");
    while (next != NULL) {
        printf("-> %s (%s)", next->nom, get_type(next->type));
        next = next->suivant;
    }
}

void afficher_fonction(fonction_t *fonction)
{
    if (fonction == NULL) {
        return;
    }
    printf("Fonction: %s\n", fonction->nom);
    printf("Type: %s\n", (fonction->type == _INT) ? "int" : "void");
    printf("Arguments:");
    if (fonction->arguments != NULL)
        afficher_liste(fonction->arguments);
    else
        printf(" aucun");
    printf("\n");
    if (fonction->declarations != NULL) {
        afficher_symb(fonction->declarations);
    }
    else {
        printf("Aucune déclarations\n");
    }
    printf("\n\n");
}

param_t *create_param(type_t type, const char *nom)
{
    param_t *param = malloc(sizeof(param_t));
    param->nom = strdup(nom);
    param->type = type;
    return param;
}
