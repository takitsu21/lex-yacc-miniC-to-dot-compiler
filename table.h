#ifndef _TABLE_H
#define _TABLE_H
#include "symboles.h"
#define TAILLE 103 /*nbr premier de preference */

typedef struct _param_t
{
    type_t type;
    char *nom;
} param_t;
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

symbole_t *table[TAILLE];
void insert_next_symb(symbole_t *symb1, symbole_t *symb2);
int hash(char *nom);
void table_reset();
symbole_t *inserer(char *nom);
void affiche();
symbole_t *create_symb(const char * nom, void* type);
record_t *add_record(const char *nom, type_t type);
#endif