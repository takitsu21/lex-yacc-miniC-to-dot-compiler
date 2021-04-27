#include "symboles.h"
extern int yylineno;
#define TAILLE 103

node_t *create_node(const char *nom, int val, void *bt, void *type)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(nom);
    node->type = (type_t)type;
    node->suivant = NULL;
    node->fils = NULL;
    // show_node(node);
    // printf("node created %s\n", node->nom);
    return node;
}

void insert_to_tree(node_t *node, int cursor)
{
    tree[cursor] = node;
}

node_t *mk_node(node_t *L, const char *parent_name, node_t *R)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(parent_name);
    node->type = (type_t)NULL;
    node->suivant = NULL;

    // debug_node(node);
    return node;
}

// void insert_node(node_t *node, char *nom, int cursor)
// {
//     node_t *s;
//     node_t *precedent;

//     s = tree[cursor];
//     precedent = NULL;

//     while (s != NULL)
//     {
//         if (strcmp(s->nom, nom) == 0)
//             return;
//         precedent = s;
//         s = s->left;
//     }
//     if (precedent == NULL)
//     {
//         tree[cursor] = (node_t *)malloc(sizeof(node_t));
//         s = tree[cursor];
//     }
//     else
//     {
//         precedent->left = (node_t *)malloc(sizeof(node_t));
//         s = precedent->left;
//     }

//     s->nom = strdup(nom);
//     s->left = NULL;
//     // tree[cursor]->suivant[0] = s;
// }

void init()
{
    tree = (node_t **)calloc(100, sizeof(node_t));
    functions = (node_t *)malloc(sizeof(node_t));
}

// void display(node_t *ptr, int level)
// {
//     if (ptr == NULL) /*Base Case*/
//         return;
//     else
//     {
//         display(ptr->right, level + 1);
//         printf("\n");
//         for (int i = 0; i < level; i++)
//             printf("    ");
//         printf("%s\n", ptr->nom != NULL ? ptr->nom : "NULL");
//         display(ptr->left, level + 1);
//     }
// }

void print_all_next(node_t *suivants, int level)
{
    // display(suivants, level);
    if (suivants == NULL)
    {
        printf("---------------\n");
        return;
    }
    print_all_next(suivants->suivant, level);
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

        if (node->suivant != NULL)
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
    // p = malloc(sizeof(node_t));
    // p->fils = NULL;
    // p->suivant = NULL;
    q = p;
    while (q->suivant != NULL)
    {
        q = q->suivant;
    }
    q->suivant = c;
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