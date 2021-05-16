#ifndef _SYMBOLES_H
#define _SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
#include <string.h>
#define TAILLE 211 /*nbr premier de preference */
#define KNRM "\x1B[0m"
#define KRED "\x1B[31m"
#define KYEL "\x1B[33m"

typedef enum _type_t
{
    _INT,
    _VOID
} type_t;

typedef struct _symbole_t
{
    char *nom;
    int scope;
    int tab_dimension;
    type_t type;
    struct _symbole_t *suivant;
} symbole_t;

typedef struct _node_t
{
    char *nom;
    type_t type;
    char *code;
    int is_func;
    int is_appel;
    struct _node_t *fils;
    struct _node_t *suivant;
} node_t;

typedef struct _param_t
{
    type_t type;
    char *nom;
} param_t;
typedef struct _liste_t
{
    param_t *param;
    struct _liste_t *suivant;
} liste_t;

typedef struct _fonction_t
{
    type_t type;
    char *nom;
    liste_t *arguments;
    struct _symbole_t **local;
} fonction_t;

symbole_t *global[TAILLE];
fonction_t *fonctions[TAILLE];
symbole_t *local[TAILLE];

int isdigits(const char *str);
node_t *mk_single_node(const char *nom);
void insert_next(node_t *p, node_t *c);
node_t *create_node(const char *nom, void *type);
void insert_node(node_t *src, node_t *dst);
node_t *create_node_children(node_t *p, node_t *c1, node_t *c2, node_t *c3, node_t *c4);
char *get_type(type_t type);
void generateDot(node_t *node, const char *filename);
void generateDotContent(FILE *fp, node_t *node, node_t *parent);
void check_semantic_errors(node_t *node, type_t return_type, const char *func_name);
void check_return(node_t *node, type_t return_type);
int linked_list_size(liste_t *linked_list);
int linked_node_size(node_t *node);
void check_declared(node_t *func, const char *func_name);
void check_tab(node_t *tab);
void insert_next_symb(symbole_t *symb1, symbole_t *symb2);
int hash(char *nom);
void table_reset();
symbole_t *inserer(symbole_t **table, char *nom);
void affiche(symbole_t **table);
symbole_t *create_symb(const char *nom, void *type);
void concatener_listes(liste_t *l1, liste_t *l2);
liste_t *creer_liste(param_t *p);
void semantic_error(const char *error);
fonction_t *ajouter_fonction(type_t type, const char *nom, liste_t *args);
param_t *create_param(type_t type, const char *nom);
int listes_egales(liste_t *l1, liste_t *l2);
int tab_size(symbole_t *tab);
symbole_t *insert_next_table(symbole_t **table, const char *nom, symbole_t *s);
void free_tree(node_t *tree);
void free_functions(fonction_t **fs);
void free_liste(liste_t *l);
void free_st(symbole_t **st);
void check_type(node_t *e, const char *func_name);
int search_var_in_func(const char *func_name, const char *nom);
symbole_t *search_var(symbole_t **st, const char * nom);
#endif