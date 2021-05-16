#include "symboles.h"

extern int yylineno;
extern int yylineno;
extern int scope;
extern int yycol;

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

void generateDot(node_t *node, const char *filename)
{
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

int linked_node_size(node_t *node)
{
    int i = 0;
    node_t *q = node;
    while (q != NULL)
    {
        i++;
        q = q->suivant;
    }
    return i;
}

// void check_func(node_t* f, )

void check_semantic_errors(node_t *node, type_t return_type, const char *func_name)
{
    while (node != NULL)
    {
        int h = hash(node->nom);
        if (node->is_appel != NULL && fonctions[h] == NULL)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "La fonction %s n'est pas défini", node->nom);
            semantic_error(tmp);
        }
        if (node->fils != NULL)
        {
            if (strcmp("RETURN", node->nom) == 0)
            {
                check_return(node->fils, return_type);
            }
            else if (node->fils->fils != NULL && strcmp("IF", node->nom) == 0)
            {
                check_type(node->fils->fils, func_name);
            }
            else if (strcmp(":=", node->nom) == 0 && node->fils->suivant != NULL)
            {
                check_type(node->fils, func_name);
            }
            else if (strcmp("SWITCH", node->nom) == 0)
            {
                check_type(node->fils, func_name);
            }
        }

        if (node->fils != NULL)
        {
            check_semantic_errors(node->fils, return_type, func_name);
        }
        node = node->suivant;
    }
}

void check_return(node_t *node, type_t return_type)
{
    while (node != NULL)
    {
        if (fonctions[hash(node->nom)] != NULL &&
            fonctions[hash(node->nom)]->type != node->type)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "Vous ne pouvez pas renvoyer de valeurs dans la fonction %s car son type est %s.", node->nom, get_type(fonctions[hash(node->nom)]->type));
            semantic_error(tmp);
        }
        if (node->fils != NULL)
        {
            check_return(node->fils, return_type);
        }
        node = node->suivant;
    }
}

void generateDotContent(FILE *fp, node_t *node, node_t *parent)
{
    while (node != NULL)
    {
        node->code = malloc(sizeof(char));
        sprintf(node->code, "%p", (void *)node);

        if (strcmp("EXTERN", node->nom) == 0)
        {
            node = node->suivant;
            continue;
        }

        if (node->is_func != NULL)
        {
            fprintf(fp, "node_%s [label=\"%s, %s\" shape=invtrapezium color=blue];\n", node->code, node->nom, get_type(node->type));
        }
        else
        {
            if (fonctions[hash(node->nom)] != NULL)
            {
                int params_size = linked_list_size(fonctions[hash(node->nom)]->arguments);
                int node_size = linked_node_size(node->fils);
                if (params_size != node_size)
                {
                    char *tmp = malloc(sizeof(char));
                    sprintf(tmp, "Mauvais nombre d'arguments lors l'appel de la fonction %s, requis %d, lors de l'appel %d fournis.", node->nom, params_size, node_size);
                    semantic_error(tmp);
                }
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

void check_declared(node_t *func, const char *func_name)
{
    while (func != NULL)
    {
        int h = hash(func->nom);

        if (func->fils == NULL && !isdigits(func->nom) && strcmp("BREAK", func->nom))
        {
            if (fonctions[h] != NULL || fonctions[hash(func_name)]->local[h] != NULL || global[h] != NULL)
            {
            }
            else
            {
                char *tmp = malloc(sizeof(char));
                sprintf(tmp, "%s n'a pas encore été déclaré.", func->nom);
                semantic_error(tmp);
            }
        }
        if (func->fils)
        {
            check_declared(func->fils, func_name);
        }
        func = func->suivant;
    }
}

int isdigits(const char *str)
{
    int number = 0;
    for (int i = 0; str[i] != '\0'; i++)
    {
        if (isdigit(str[i]) != 0)
            number++;
    }
    return number == strlen(str);
}

void check_tab(node_t *tab)
{
    int var_size = 0;
    node_t *var = tab->fils;
    symbole_t *to_use = search_var(local, var->nom);
    if (to_use == NULL)
    {
        to_use = search_var(global, var->nom);
    }
    if (to_use != NULL && scope >= to_use->scope)
    {
        // pas d'erreurs
    }
    else
    {
        char *tmp = malloc(sizeof(char));
        sprintf(tmp, "La variable %s n'a pas encore été déclaré.\n", var->nom);
        semantic_error(tmp);
    }
    if (var->suivant != NULL)
    {
        var_size = linked_node_size(var->suivant);
    }
    else
    {
        var_size = tab_size(to_use);
    }
    int decl_size = tab_size(to_use);
    if (to_use->tab_dimension - var_size < 0)
    {
        char *tmp = malloc(sizeof(char));
        sprintf(tmp, "La dimension à laquelle vous essayé d'accéder n'est pas la bonne.");
        semantic_error(tmp);
    }
}

int hash(char *nom)
{
    int i;
    int taille = strlen(nom);
    int r = 0;
    for (i = 0; i < taille; i++)
        r = ((r << 8) + nom[i]) % TAILLE;
    return r;
}

void table_reset(symbole_t **table)
{
    int i;
    for (i = 0; i < TAILLE; i++)
    {
        table[i] = NULL;
    }
}

symbole_t *inserer(symbole_t **table, char *nom)
{
    int h;
    symbole_t *s;
    symbole_t *precedent;

    h = hash(nom);
    s = table[h];
    precedent = NULL;

    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0)
        {
            return s;
        }
        precedent = s;
        s = s->suivant;
    }
    if (precedent == NULL)
    {
        table[h] = (symbole_t *)malloc(sizeof(symbole_t));
        s = table[h];
    }
    else
    {
        precedent->suivant = (symbole_t *)malloc(sizeof(symbole_t));
        s = precedent->suivant;
    }

    s->nom = strdup(nom);
    s->suivant = NULL;
    s->scope = scope;
    return s;
}

symbole_t *create_symb(const char *nom, void *type)
{
    symbole_t *s = (symbole_t *)malloc(sizeof(symbole_t));
    s->nom = strdup(nom);
    s->type = (type_t)type;
    s->scope = scope;
    return s;
}

void insert_next_symb(symbole_t *symb1, symbole_t *symb2)
{
    symbole_t *head = symb1;
    while (head->suivant != NULL)
    {
        head = head->suivant;
    }
    head->suivant = symb2;
}

void affiche(symbole_t **table)
{
    int i = 0;
    symbole_t *s;
    for (i = 0; i < TAILLE; i++)
    {
        if (table[i] == NULL)
        {
            printf(" orpo table[%d]->NULL\n", i);
        }
        else
        {
            s = table[i];
            printf("table[%d] scope : %d -> %s ", i, s->scope, s->nom);
            while (s->suivant != NULL)
            {
                printf("[%s] scope : %d ->", s->nom, s->scope);
                s = s->suivant;
            }
            printf("NULL\n");
        }
    }
}

liste_t *creer_liste(param_t *p)
{
    liste_t *liste;
    liste = (liste_t *)malloc(sizeof(liste_t));
    liste->param = p;
    liste->suivant = NULL;
    return liste;
}

void concatener_listes(liste_t *l1, liste_t *l2)
{
    liste_t *l = l1;
    while (l->suivant != NULL)
    {
        l = l->suivant;
    }
    l->suivant = l2;
}

void semantic_error(const char *error)
{
    fprintf(stderr, "%sSemantic error : %s\n", KRED, error);
    fprintf(stderr, "%s", KNRM);
    exit(1);
}

fonction_t *ajouter_fonction(type_t type, const char *nom, liste_t *args)
{
    int h;
    fonction_t *f;
    fonction_t *precedent;
    fonction_t *nouvelle_fonction;
    h = hash(nom);
    f = fonctions[h];
    if (f != NULL && strcmp(f->nom, nom) == 0)
    {
        /* on a trouvé une fonction portant le meme nom */
        char *tmp = malloc(sizeof(char));
        sprintf(tmp, "Re-déclaration de la fonction %s", f->nom);
        semantic_error(tmp);
        return NULL;
    }
    nouvelle_fonction = (fonction_t *)malloc(sizeof(fonction_t));
    fonctions[h] = nouvelle_fonction;
    f = fonctions[h];
    f->type = type;
    f->nom = strdup(nom);
    f->arguments = args;
    f->local = malloc(sizeof(local));
    memcpy(f->local, local, sizeof(local));
    return f;
}
int listes_egales(liste_t *l1, liste_t *l2)
{
    liste_t *liste;
    for (liste = l1; liste != NULL; liste = liste->suivant)
    {
        if ((l2 == NULL) || (l2->param->type != liste->param->type))
            return 0;
        l2 = l2->suivant;
    }
    if (l2 != NULL)
        return 0;
    return 1;
}

int tab_size(symbole_t *tab)
{
    int i = 0;
    symbole_t *q = tab;
    while (q->suivant != NULL)
    {
        i++;
        q = q->suivant;
    }
    return i;
}

param_t *create_param(type_t type, const char *nom)
{
    param_t *param = malloc(sizeof(param_t));
    param->nom = strdup(nom);
    param->type = type;
    return param;
}

void free_tree(node_t *tree)
{
    while (tree != NULL)
    {
        free(tree->nom);
        if (tree->fils != NULL)
        {
            free_tree(tree->fils);
            free(tree);
        }
        else
        {
            free(tree);
        }
        tree = tree->suivant;
    }
}

void free_st(symbole_t **st)
{
    int i = 0;
    for (i = 0; i < TAILLE; i++)
    {
        if (st[i] != NULL)
        {
            while (st[i] != NULL)
            {
                if (st[i]->nom != NULL)
                {
                    free(st[i]->nom);
                }

                st[i] = st[i]->suivant;
            }
            free(st[i]);
        }
    }
}

void free_functions(fonction_t **fs)
{
    int i = 0;
    for (i = 0; i < TAILLE; i++)
    {
        if (fs[i] != NULL)
        {
            free(fs[i]->nom);
            table_reset(fs[i]->local);
            free_liste(fs[i]->arguments);
            free(fs[i]);
        }
    }
}

void free_liste(liste_t *l)
{
    if (l == NULL)
    {
        return;
    }
    if (l->suivant != NULL)
    {
        free_liste(l->suivant);
    }
    if (l->param != NULL)
    {
        free(l->param->nom);
        free(l->param);
    }
    free(l);
}

void check_type(node_t *e, const char *func_name)
{
    symbole_t *s;
    while (e != NULL)
    {
        int h = hash(e->nom);
        if (fonctions[hash(e->nom)] != NULL && fonctions[hash(e->nom)]->type == _VOID)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "%s : Type void rencontré dans une expression, int attendu.", e->nom);
            semantic_error(tmp);
        }
        if (e->type == _VOID)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "%s : Type void rencontré dans une expression, int attendu.", e->nom);
            semantic_error(tmp);
        }

        if (e->fils != NULL)
        {
            check_type(e->fils, func_name);
        }
        e = e->suivant;
    }
}

int search_var_in_func(const char *func_name, const char *nom)
{
    for (int i = 0; i < TAILLE; i++)
    {
        if (fonctions[i] != NULL && search_var(fonctions[i]->local, nom) != NULL)
        {
            return 1;
        }
    }
    return 0;
}

symbole_t *search_var(symbole_t **st, const char *nom)
{
    for (int i = 0; i < TAILLE; i++)
    {
        if (st[i] != NULL)
        {
            symbole_t *q = st[i];
            while (q != NULL)
            {
                if (q->nom != NULL && !strcmp(q->nom, nom))
                {
                    return q;
                }
                q = q->suivant;
            }
        }
    }
    return NULL;
}