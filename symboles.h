#ifndef SYMBOLES_H
#define SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TAILLE 103 /*nbr premier de preference */


typedef enum
{
    _INT,
    _VOID
} type_t;

typedef struct _symbole
{
    char *nom;
    int valeur;
    type_t type;
    struct _symbole *suivant;
} symbole;
symbole *table[TAILLE];

void affiche();
symbole *inserer(char *nom);
void table_reset();
int hash(char *nom);
#endif