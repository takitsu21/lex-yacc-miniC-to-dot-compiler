#include "symboles.h"
extern int yylineno;
#define TAILLE 103
no_node = 0;

node_t *create_node(const char *nom, void* type)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(nom);
    if (type != NULL) {
        node->type = (type_t)type;
    }

    node->suivant = NULL;
    node->fils = NULL;
    node->code = (char *)malloc(sizeof(char));
    node->no_node = ++no_node;
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

        if (node->type != NULL)
        {
            printf("Node: %s, %s\n", node->nom, get_type(node->type));
        }
        else
        {
            printf("Node: %s\n", node->nom);
        }

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
    generateDot(node);
}

void generateDot(node_t *node)
{
    srand((unsigned int)time(NULL));
    // printf("digraph exempleminiC {\n");

    FILE *fp = fopen("test.dot", "w");
    fp = fopen("test.dot", "a");

    if (fp == NULL)
    {
        printf("file can't be opened");
        exit(1);
    }
    fprintf(fp, "digraph mon_programme {\n");
    generateDotContent(fp, node, NULL);
    fprintf(fp, "}\n");
    // write_file("test", ptr);
}

char *generateHex(int length)
{
    const char *digits = "0123456789ABCDEF";
    char str[length + 1];
    str[0] = *(digits + (1 + rand() % 15));

    int i = 1;
    for (; i < length; i++)
    {
        str[i] = *(digits + (rand() % 16));
    }

    str[i] = '\0';
    char *ret = calloc(strlen(str) + 1, sizeof(char));
    strcpy(ret, str);
    return ret;
}

void generateDotContent(FILE* fp, node_t *node, node_t *parent)
{
    while (node != NULL)
    {
        node->code = generateHex(16);

        if (node->is_func != NULL)
        {
            printf("get type %s\n", get_type(node->type));
            fprintf(fp, "node_%s [label=\"%s, %s\" shape=invtrapezium color=blue];\n", node->code, node->nom, get_type(node->type));

        }
        else
        {
            // FIXME: printd peut être n'importe quel fonction externe, a changer.
            if (strcmp("printd", node->nom) == 0)
            {
                fprintf(fp, "node_%s [label=\"%s\" shape=septagon];\n", node->code, node->nom);
            }
            else if (strcmp("RETURN", node->nom) == 0)
            {
                fprintf(fp, "node_%s [label=\"%s\" shape=trapezium color=blue];\n", node->code, node->nom);
            }
            else if (strcmp("BREAK", node->nom) == 0)
            {
                fprintf(fp, "node_%s [label=\"%s\" shape=box];\n", node->code, node->nom);
            }
            else if (strcmp("IF", node->nom) == 0)
            {
                fprintf(fp, "node_%s [label=\"%s\", shape=diamond];\n", node->code, node->nom);
            }
            else
            {
                fprintf(fp, "node_%s [label=\"%s\"];\n", node->code, node->nom);
            }
        }

        if (node->fils != NULL)
        {
            generateDotContent(fp, node->fils, node);
        }

        if (parent != NULL)
        {
            fprintf(fp, "node_%s -> node_%s\n", parent->code, node->code);
        }

        node = node->suivant;
    }
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
    // node->type = (type_t)NULL;
    node->suivant = NULL;
    node->fils = NULL;
    node->no_node = ++no_node;
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

    q->suivant = c;
}

void insert_next_brother(node_t *p, node_t *brother)
{
    node_t *q;

    q = p->fils;
    while (q->suivant != NULL)
    {
        q = q->suivant;
    }
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
    case _VOID:
        return "void";
    default:
        break;
    }
    return "";
}

void write_file(const char *filename, const char *text)
{
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        printf("file can't be opened");
        exit(1);
    }
    fputs(text, fp);
    fclose(fp);
}

void gen_code_affectation(node_t *node)
{
    char *ret = strcpy(ret, "node_affect_%s");
    sprintf(ret, ret, node->nom);
}

void concatenate(char *ptr, const char *str, ...)
{
    char *ret = "";
    char *arg;

    va_list args;
    arg = str;
    va_start(args, str);
    while (arg != NULL)
    {
        strcat(ret, arg);
        arg = va_arg(args, char *);
    }
    va_end(args);
    printf("copy");
    strcpy(ptr, ret);
}
