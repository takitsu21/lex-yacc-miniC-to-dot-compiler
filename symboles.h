#ifndef _SYMBOLES_H
#define _SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

typedef struct _node_t
{
    char *nom;
    bloc_type_t bt; // si null = opération simple (ex: +, :=, <, ...)
    type_t type;
    struct _node_t *left;
    struct _node_t *right;
    struct _node_t *suivant;
} node_t;


node_t **tree;
node_t* functions;

void affiche();
void insert_node(node_t *node, char* nom, int cursor);
node_t *create_node(const char* nom, int val, void *bt, void* type);
#endif