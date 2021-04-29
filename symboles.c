#include "symboles.h"
extern int yylineno;
#define TAILLE 103

node_t *create_node(const char *nom, void *type)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(nom);
    node->type = (type_t)type;
    node->suivant = NULL;
    node->fils = NULL;
    node->code = (char*)malloc(sizeof(char));
    return node;
}

void init()
{
    tree = (node_t **)calloc(100, sizeof(node_t));
    functions = (node_t *)malloc(sizeof(node_t));
}

void insert_node(node_t *src, node_t *dst)
{
    node_t *next = dst;
    while (next->suivant != NULL)
    {
        next = next->suivant;
    }
    next->suivant = src;
}

void printTabs(int count)
{
    for (int i = 0; i < count; i++)
    {
        putchar('\t');
    }
}

void printTreeRecursive(node_t *node, int level)
{
    while (node != NULL)
    {
        printTabs(level);
        printf("Node: %s\n", node->nom);

        if (node->fils != NULL)
        {
            printTabs(level);
            printf("Children:\n");
            printTreeRecursive(node->fils, level + 1);
        }

        node = node->suivant;
    }
}

void visualise(node_t *node)
{
    printTreeRecursive(node, 0);
}

node_t *create_node_children(node_t *p, node_t *c1, node_t *c2, node_t *c3, node_t *c4)
{
    if (c1 != NULL)
    {
        p->fils = c1;
    }
    if (c2 != NULL)
    {
        p->fils->suivant = c2;
    }
    if (c3 != NULL)
    {
        p->fils->suivant->suivant = c3;
    }
    if (c4 != NULL)
    {
        p->fils->suivant->suivant->suivant = c4;
    }
    return p;
}

node_t *mk_single_node(const char *nom)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(nom);
    node->type = (type_t)NULL;
    node->suivant = NULL;
    node->fils = NULL;
    node->code = malloc(sizeof(char));
    return node;
}

void insert_children(node_t *t, node_t *c1)
{
    t->fils = c1;
}

void insert_brother(node_t *c, node_t *b)
{
    c->suivant = b;
}

void insert_next(node_t *p, node_t *c)
{
    node_t *q;

    q = p;
    while (q->suivant != NULL)
    {
        q = q->suivant;
    }
    printf("\n");

    q->suivant = c;
}

void insert_next_brother(node_t *p, node_t *brother)
{
    insert_next(p->fils, brother);
}

void print_children(node_t *ll)
{
    node_t *next = ll->fils;
    while ((next = next->suivant) != NULL)
    {
        printf("%s -> ", next->nom);
    }
}

void print_next(node_t *ll)
{
    node_t *next = ll;
    while ((next = next->suivant) != NULL)
    {
        printf("%s\n", next->nom);
    }
}

char *get_type(type_t type)
{
    switch (type)
    {
    case _INT:
    return "int";
        break;

    default:
        return "void";
        break;
    }
}


void write_file(const char *filename, const char *text) {
    FILE *fp = fopen(filename, "w+");
    if (fp == NULL) {
        printf("file can't be opened");
        exit(1);
    }
    fputs(text, fp);
    fclose(fp);
}