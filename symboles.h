#ifndef _SYMBOLES_H
#define _SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define TAILLE 103 /*nbr premier de preference */

typedef enum _type_t
{
    _INT,
    _VOID
} type_t;

typedef struct _param_t
{
    type_t type;
    char *nom;
} param_t;

typedef struct _symbole
{
    char *nom;
    int valeur;
    param_t type;
    struct _symbole *suivant;
} symbole;

typedef struct _liste_t
{
    param_t param;
    struct _liste_t *suivant;
} liste_t;

typedef struct _fonction_t
{
    type_t type;
    char *nom;
    liste_t *arguments;
    struct _fonction_t *suivant;
} fonction_t;

typedef struct _programme_t
{
    liste_t *declarations;
    liste_t *fonctions;
} programme_t;

symbole *table[TAILLE];

void affiche();
symbole *inserer(char *nom);
void table_reset();
int hash(char *nom);
void assigne(symbole *table[], const char *var, int value);
liste_t *creer_liste(param_t p);
liste_t *concatener_listes(liste_t *l1, liste_t *l2);
void afficher_liste(liste_t *liste);
int listes_egales(liste_t *l1, liste_t *l2);
fonction_t *ajouter_fonction(type_t type, char *nom, liste_t *args);
param_t *create_param(type_t type);
#endif