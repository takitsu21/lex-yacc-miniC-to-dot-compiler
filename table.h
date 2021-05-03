#ifndef _TABLE_H
#define _TABLE_H
#include "symboles.h"
#define TAILLE 103 /*nbr premier de preference */



symbole_t *global[TAILLE];
fonction_t *fonctions[TAILLE];
symbole_t *local[TAILLE];
void insert_next_symb(symbole_t *symb1, symbole_t *symb2);
int hash(char *nom);
void table_reset();
symbole_t *inserer(symbole_t **table, char *nom);
void affiche(symbole_t **table);
symbole_t *create_symb(const char * nom, void* type);
record_t *add_record(const char *nom, type_t type);
liste_t *concatener_listes(liste_t *l1, liste_t *l2);
liste_t *creer_liste(param_t *p);
void semantic_error(const char *error);
fonction_t *ajouter_fonction(type_t type, const char *nom, liste_t *args, symbole_t *declarations);
void afficher_fonction(fonction_t *fonction);
param_t *create_param (type_t type, const char * nom);
int listes_egales(liste_t *l1, liste_t *l2);
void afficher_liste(liste_t *liste);
#endif