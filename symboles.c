#include "symboles.h"
#include "table.h"
extern int yylineno;
extern char *file_name;
#define TAILLE 103

node_t *create_node(const char *nom, void *type)
{
    node_t *node = (node_t *)malloc(sizeof(node_t));
    node->nom = strdup(nom);
    if (type != NULL)
    {
        node->type = (type_t)type;
    }
    node->suivant = NULL;
    node->fils = NULL;
    node->code = (char *)malloc(sizeof(char));
    return node;
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
}

void generateDot(node_t *node, const char *filename)
{
    srand((unsigned int)time(NULL));

    FILE *fp = fopen(filename, "w");
    fp = fopen(filename, "a");

    if (fp == NULL)
    {
        printf("Ouverture du fichier impossible");
        exit(1);
    }
    fprintf(fp, "digraph mon_programme {\n");
    generateDotContent(fp, node, NULL);
    fprintf(fp, "}\n");
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
    char *ret = calloc(length, sizeof(char));
    strcpy(ret, str);
    return ret;
}

int linked_list_size(liste_t *linked_list)
{
    int i = 0;
    liste_t *q = linked_list;
    while (q != NULL)
    {
        i++;
        q = q->suivant;
    }
    return i;
}

int linked_node_size(node_t *node) {
    int i = 0;
    node_t *q = node;
    while (q != NULL)
    {
        i++;
        q = q->suivant;
    }
    return i;
}

void verify_return_recursive_call(node_t *node) {
    while (node != NULL) {
        if (local[hash(node->nom)] != NULL && fonctions[hash(node->nom)] == NULL) {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "La fonction %s n'est pas encore déclaré.\n", node->nom);
            semantic_error(tmp);
        }
        if (node->fils != NULL) {
            verify_return_recursive_call(node->fils);
        }
        node = node->suivant;
    }
}

void verify_return_statements(node_t *node, type_t return_type)
{
    while (node != NULL)
    {
        printf("%d %s\n", node->is_func, node->nom);


        if (strcmp("RETURN", node->nom) == 0) {
            if (node->type != return_type) {
                char *tmp = malloc(sizeof(char));
                sprintf(tmp, "Le type de renvoie %s n'est pas le bon.\n", node->nom);
                semantic_error(tmp);
            }
            // verify_return_recursive_call(node->fils);
        }
        if (node->fils != NULL)
        {
            verify_return_recursive_call(node->fils);
            verify_return_statements(node->fils, return_type);
        }
        node = node->suivant;
    }
}

void generateDotContent(FILE *fp, node_t *node, node_t *parent)
{
    while (node != NULL)
    {
        node->code = generateHex(16);

        if (strcmp("EXTERN", node->nom) == 0)
        {
            node = node->suivant;
            continue;
        }

        if (node->is_func != NULL)
        {
            printf("get type %s\n", get_type(node->type));
            fprintf(fp, "node_%s [label=\"%s, %s\" shape=invtrapezium color=blue];\n", node->code, node->nom, get_type(node->type));
        }
        else
        {
            if (fonctions[hash(node->nom)] != NULL)
            {
                printf("fonctions[hash(node->nom)] %s\n", fonctions[hash(node->nom)]->nom);

                fprintf(fp, "node_%s [label=\"%s\" shape=septagon];\n", node->code, fonctions[hash(node->nom)]->nom);
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

int expression_match(node_t *e1, node_t *e2)
{
    if (e1->type != e2->type)
    {
        printf("Les expression %s (%s) et %s (%s) n'ont pas le meme type", e1->nom, get_type(e1->type), e2->nom, get_type(e2->type));
        exit(1);
    }
    return 1;
}

void check_call_func(node_t *func_call, node_t *list_expr)
{
    if (fonctions[hash(func_call->nom)] == NULL)
    {
        char *tmp = malloc(sizeof(char));
        sprintf(tmp, "La fonction %s n'a pas encore été déclaré.\n", func_call->nom);
        semantic_error(tmp);
    }
    node_t *q = list_expr;
    liste_t *args = fonctions[hash(func_call->nom)]->arguments;
    if (linked_node_size(q) != linked_list_size(args))
    {
        char *tmp = malloc(sizeof(char));
        sprintf(tmp, "Il n'y a pas le même nombre d'arguments dans l'appel de la fonction %s\n", func_call->nom);
        semantic_error(tmp);
    }
    while (q != NULL)
    {
        if (args == NULL)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "Il n'y a pas le même nombre d'arguments dans l'appel de la fonction %s\n", func_call->nom);
            semantic_error(tmp);
        }
        else if (q->type != args->param->type)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "La variable %s n'a pas le même type que l'argument %s\n", func_call->nom);
            semantic_error(tmp);
        }
        args = args->suivant;
        q = q->suivant;
    }
}