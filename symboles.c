#include "symboles.h"
extern int yylineno;
#define TAILLE 103

void affiche()
{
    int i = 0;
    node_t *s;
    for (i = 0; i < TAILLE; i++)
    {
        if (tree[i] == NULL)
        {
            printf(" orpo table[%d]->NULL\n", i);
        }
        else
        {
            s = tree[i];
            printf("table[%d]-> %s ", i, s->nom);
            while (s->left != NULL)
            {
                printf("[%s]->", s->nom);
                s = s->left;
            }
            printf("NULL\n");
        }
    }
}

node_t *create_node(const char *nom, int val, void *bt, void *type)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(nom);
    node->bt = (bloc_type_t)bt;
    node->type = (type_t)type;
    node->left = NULL;
    node->right = NULL;
    node->suivant = NULL;
    // show_node(node);
    // printf("node created %s\n", node->nom);
    return node;
}

void insert_to_tree(node_t *node, int cursor)
{
    tree[cursor] = node;
}

void insert_next_node(node_t *src_node, node_t *dst_node)
{
    node_t *next;
    while ((next = src_node->left) != NULL)
        ;
    next->left = dst_node;
}

node_t *mk_node2(node_t *L, node_t *P, node_t *R)
{
    P->right = R;
    P->left = L;
    // debug_node(P);
    return P;
}

void display(node_t *ptr, int level)
{
    int i;
    if (ptr == NULL) /*Base Case*/
        return;
    else
    {
        display(ptr->right, level + 1);
        printf("\n");
        for (i = 0; i < level; i++)
            printf("    ");
        printf("%s\n", ptr->nom);
        display(ptr->left, level + 1);
    }
}

node_t *mk_node(node_t *L, const char *parent_name, node_t *R)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(parent_name);
    node->right = R;
    node->left = L;
    // debug_node(node);
    return node;
}

void debug_node(node_t *P)
{
    printf("[%d] GAUCHE : %s\n", yylineno, P->left != NULL ? P->left->nom : "NULL");
    printf("[%d] PARENT : %s\n", yylineno, P->nom != NULL ? P->nom : "NULL", yylineno);
    printf("[%d] DROITE : %s\n", yylineno, P->right != NULL ? P->right->nom : "NULL");
}

void insert_node(node_t *node, char *nom, int cursor)
{
    node_t *s;
    node_t *precedent;

    s = tree[cursor];
    precedent = NULL;

    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0)
            return;
        precedent = s;
        s = s->left;
    }
    if (precedent == NULL)
    {
        tree[cursor] = (node_t *)malloc(sizeof(node_t));
        s = tree[cursor];
    }
    else
    {
        precedent->left = (node_t *)malloc(sizeof(node_t));
        s = precedent->left;
    }

    s->nom = strdup(nom);
    s->left = NULL;
    // tree[cursor]->suivant[0] = s;
}

void init()
{
    tree = (node_t **)calloc(100, sizeof(node_t));
    functions = (node_t*)malloc(sizeof(node_t));
}