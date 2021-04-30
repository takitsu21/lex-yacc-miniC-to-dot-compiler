#ifndef _SYMBOLES_H
#define _SYMBOLES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

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
    type_t type;
    char *code;
    int no_node;
    int is_func;
    struct _node_t *fils;
    struct _node_t *suivant;
} node_t;


node_t **tree;
node_t* functions;
extern node_t *instructions;


void affiche();
node_t *mk_single_node(const char *nom);
void insert_next(node_t *p, node_t *c);
void print_children(node_t *ll);
void print_next(node_t *ll);
void insert_children(node_t *t, node_t *c1);
void insert_brother(node_t *c, node_t *b);
node_t *create_node(const char *nom, void* type);
void printTreeRecursive(node_t *node, int level);
void printTabs(int count);
void print_all_next(node_t *suivants, int level);
void insert_node(node_t *src, node_t *dst);
node_t *create_node_children(node_t *p, node_t *c1, node_t *c2, node_t *c3, node_t *c4);
void visualise(node_t *node);
void printTreeRecursive(node_t *node, int level);
void printTabs(int count);
void init();
void insert_next_brother(node_t *p, node_t *brother);
void write_file(const char *filename, const char *text);
char *get_type(type_t type);
void concatenate(char *ptr, const char *str, ...);
void generateDot(node_t *node);
void generateDotContent(FILE* fp, node_t *node, node_t *parent);
char *generateHex(int length);
#endif