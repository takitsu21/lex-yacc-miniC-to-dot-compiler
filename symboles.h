#ifndef _SYMBOLES_H
#define _SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define TAILLE 103 /*nbr premier de preference */

// typedef struct _param_t
// {
//     type_t type;
//     char *nom;
// } param_t;

// typedef struct _op_t
// {
//     int inst1;
//     char op;
//     int inst2;
// } op_t;

// typedef struct _symbole
// {
//     char *nom;
//     int valeur;
//     param_t type;
//     struct _symbole *suivant;
// } symbole;

// typedef struct _symbole_t2
// {
//     liste_t *arguments;
//     liste_t *declarations;
// } symbole_t2;

// typedef struct _liste_t
// {
//     symbole *s;
//     struct _liste_t *suivant;
// } liste_t;

// typedef struct _fonction_t
// {
//     type_t type;
//     char *nom;
//     liste_t *arguments;
//     // liste_t *declarations;
//     bloc_t* bloc;
//     struct _fonction_t *suivant;
// } fonction_t;

// typedef struct _bloc_t
// {
//     liste_t *declarations;
//     liste_t *instructions;
// } bloc_t;


// ================================================

typedef enum _type_t
{
    _INT,
    _VOID
} type_t;

typedef enum _bloc_type_t
{
    _FOR,
    _WHILE,
    _SWITCH,
    _IF
} bloc_type_t;

typedef struct _node_for_t
{
    struct _node_t *init;
    struct _node_t *cond;
    struct _node_t *post_cond;
    struct _node_t *corp;
} node_for_t;

typedef struct _node_if_t
{
    struct _node_t *cond;
    struct _node_t *then;
    struct _node_t *_else;
} node_if_t;

typedef struct _node_t
{
    char *nom;
    int val;
    bloc_type_t bt; // si null = opération simple (ex: +, :=, <, ...)
    type_t type;
    struct _node_t *left;
    struct _node_t *right;
    struct _node_for_t *for_loop;
    struct _if_t *if_cond;
} node_t;



// suivant = [node -> [], ]

//     dot
//    /   \
// name (i)  val (0)
// dot_element_t **tab = malloc(sizeof(dot_element_t));
// tab[0] = inst1
// tab[1] = inst2
// etc...
// [[func1 -> [instru -> ...], inst2 -> ...], [func2 -> ...]]
/*
cursor = 0;

1fct() -> {
    add_node(cursor, create_node(1er bloc))
}

*/

// symbole *table[TAILLE];

node_t **tree;


void affiche();
// symbole *inserer(char *nom);
// void table_reset();
// int hash(char *nom);
// void assigne(symbole *table[], const char *var, int value);
// liste_t *creer_liste(param_t p);
// liste_t *concatener_listes(liste_t *l1, liste_t *l2);
// void afficher_liste(liste_t *liste);
// int listes_egales(liste_t *l1, liste_t *l2);
// fonction_t *ajouter_fonction(type_t type, char *nom, liste_t *args);
// param_t *create_param(type_t type);
void insert_node(node_t *node, char* nom, int cursor);
node_t *create_node(const char* nom, int val, void *bt, void* type);
#endif