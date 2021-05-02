
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

void table_reset()
{
    int i;
    for (i = 0; i < TAILLE; i++)
        table[i] = NULL;
}

symbole_t *inserer(char *nom)
{
    int h;
    symbole_t *s;
    symbole_t *precedent;

    h = hash(nom);
    s = table[h];
    precedent = NULL;

    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0) {
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


symbole_t *create_symb(const char * nom, void* type) {
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

void affiche()
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

liste_t *creer_liste(param_t p)
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

void semantic_error(const char *error) {
    fprintf(stderr, "Semantic error at line %d:%d : %s\n", yylineno, yycol, error);
    exit(1);
}
