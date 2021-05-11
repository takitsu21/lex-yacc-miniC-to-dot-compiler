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

int linked_node_size(node_t *node)
{
    int i = 0;
    node_t *q = node;
    while (q != NULL)
    {
        i++;
        // printf("node child %s\n", node->nom);
        q = q->suivant;
    }
    return i;
}

void verify_return_recursive_call(node_t *node)
{
    while (node != NULL)
    {
        if (local[hash(node->nom)] == NULL && fonctions[hash(node->nom)] == NULL)
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "La fonction %s n'est pas encore déclaré.\n", node->nom);
            semantic_error(tmp);
        }
        if (node->fils != NULL)
        {
            verify_return_recursive_call(node->fils);
        }
        node = node->suivant;
    }
}

void verify_parameters(node_t *node, const char *func_name, int acc)
{
    while (node != NULL)
    {
        if (node->fils != NULL)
        {
            if (check_param(node->fils, func_name, acc) != linked_list_size(fonctions[hash(func_name)]->arguments)) {
                char *tmp = malloc(sizeof(char));
                sprintf(tmp, "Il n'y a pas le même nombre de paramètres\n");
                semantic_error(tmp);
            }
        }
        if (node->fils != NULL)
        {
            verify_parameters(node->fils, func_name, 0);
        }
        node = node->suivant;
    }
}

int check_param(node_t *node, const char* func_name, int acc)
{
    while (node != NULL)
    {
        acc++;
        if (node->fils != NULL)
        {
            check_param(node->fils, func_name, acc);
        }
        node = node->suivant;
    }
    printf("acc : %d\n", acc);
    return acc;
}


void verify_return_statements(node_t *node, type_t return_type)
{
    while (node != NULL)
    {
        if (node->fils != NULL && strcmp("RETURN", node->nom) == 0)
        {
            check_return(node->fils, return_type);
        }
        if (node->fils != NULL)
        {
            verify_return_statements(node->fils, return_type);
        }
        node = node->suivant;
    }
}

void check_return(node_t *node, type_t return_type)
{
    while (node != NULL)
    {
        if (node->type != return_type ||
            (fonctions[hash(node->nom)] != NULL &&
            fonctions[hash(node->nom)]->type != return_type))
        {
            char *tmp = malloc(sizeof(char));
            sprintf(tmp, "Le type de renvoie %s : %s n'est pas le bon le type attendu est %s.\n", node->nom, get_type(node->type), get_type(return_type));
            semantic_error(tmp);
        }
        if (node->fils != NULL)
        {
            check_return(node->fils, return_type);
        }
        node = node->suivant;
    }
}

void verify_recursive_calls(node_t *node, const char *func_name)
{
    while (node != NULL)
    {
        if (node->fils != NULL)
        {
            verify_recursive_calls(node->fils, func_name);
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
            // verify_parameters(node, node->nom, 0);
            fprintf(fp, "node_%s [label=\"%s, %s\" shape=invtrapezium color=blue];\n", node->code, node->nom, get_type(node->type));
        }
        else
        {
            if (fonctions[hash(node->nom)] != NULL)
            {
                // printf("linked list %d, linked node %d %s\n", linked_list_size(fonctions[hash(node->nom)]->arguments), linked_node_size(node->fils), node->nom);
                if (linked_list_size(fonctions[hash(node->nom)]->arguments) != linked_node_size(node->fils)) {
                    char *tmp = malloc(sizeof(char));
                    sprintf(tmp, "Mauvais nombre d'arguments lors l'appel de la fonction %s\n", node->nom);
                    semantic_error(tmp);
                }

                // printf("fonctions[hash(node->nom)] %s\n", fonctions[hash(node->nom)]->nom);

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


void check_declared(node_t *func, const char *func_name) {
    // symbole_t **st = malloc(sizeof(local));
    // memcpy(st, fonctions[hash(func_name)]->local, sizeof(local));

    while (func != NULL) {
        int h = hash(func->nom);

        if (func->fils == NULL && !isdigits(func->nom) && strcmp("BREAK", func->nom)) {
            if (fonctions[h] != NULL || fonctions[hash(func_name)]->local[h] != NULL || global[h] != NULL) {

            } else {
                char *tmp = malloc(sizeof(char));
                sprintf(tmp, "%s n'est pas déclaré.", func->nom);
                semantic_error(tmp);
            }
        }
        if (func->fils) {
            check_declared(func->fils, func_name);
        }
        func = func->suivant;
    }
}

int isdigits(const char *str) {
    int number = 0;
    for (int i = 0; str[i] != '\0'; i++)
    {
        if (isdigit(str[i]) != 0)
            number++;
    }
    return number == strlen(str);
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

void check_tab(node_t *tab, node_t *expr) {
    symbole_t *to_use;
    node_t *var = tab->fils;
    if (local[hash(var->nom)] != NULL) {
        to_use = local[hash(var->nom)];
    } else if (global[hash(var->nom)] != NULL) {
        to_use = global[hash(var->nom)];
    } else {
        char *tmp = malloc(sizeof(char));
        sprintf(tmp, "La variable %s n'est pas encore déclaré.\n", var->nom);
        semantic_error(tmp);
    }
    int var_size;
    if (var->suivant != NULL) {
        var_size = linked_node_size(var->suivant);
    } else {
        // pas tab
        return;
    }
    int decl_size = tab_size(to_use);
    printf("decl_size : %d var_size : %d\n", decl_size, var_size);
    // if (decl_size - var_size < 0) {
    //     char *tmp = malloc(sizeof(char));
    //     sprintf(tmp, "La dimension à laquelle vous essayé d'accéder n'est pas la bonne.\n");
    //     semantic_error(tmp);
    // }

    // symbole_t *q_decl = to_use;
    // node_t * q_var = tab;
    // while (q_var != NULL) {
    //     if (atoi(q_decl->nom) <= atoi(q_var->nom)) {
    //         char *tmp = malloc(sizeof(char));
    //         sprintf(tmp, "Vous essayez d'accéder à une case du tableau qui n'a pas été déclaré.\n");
    //         semantic_error(tmp);
    //     }
    //     q_decl = q_decl->suivant;
    //     q_var = q_var->suivant;
    // }
}

void add_args_to_ts(symbole_t **st, liste_t *args, const char * func_name) {
    liste_t *q = args;
    symbole_t *s;
    while (q != NULL) {
        printf("param : %s\n", q->param->nom);
        s = inserer(st, q->param->nom);
        s->type = q->param->type;
        q = q->suivant;
    }
    // f->local = malloc(sizeof(local));
    // memcpy(f->local, local, sizeof(local));
    // affiche(st);
}


int hash(char *nom)
{
    int i, r;
    int taille = strlen(nom);
    r = 0;
    for (i = 0; i < taille; i++)
        r = ((r << 8) + nom[i]) % TAILLE;
    return r;
}

void table_reset(symbole_t **table)
{
    int i;
    for (i = 0; i < TAILLE; i++)
        table[i] = NULL;
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
            printf("Symbole %s deja déclaré\n", s->nom);
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

symbole_t *insert_next_table(symbole_t **table, const char *nom, symbole_t *s) {
    int h = hash(nom);
    symbole_t *current = table[h];
    while (current != NULL)
    {
        current = current->suivant;
    }
    current->suivant = s;
    return current;
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

void affiche_2(fonction_t **table)
{
    int i = 0;
    fonction_t *s;
    for (i = 0; i < TAILLE; i++)
    {
        if (table[i] == NULL)
        {
            // printf(" orpo table[%d]->NULL\n", i);
        }
        else
        {
            s = table[i];
            printf("table[%d] %s ", i, s->nom);
            while (s->suivant != NULL)
            {
                printf("[%s]", s->nom);
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
    while (l->suivant != NULL) {
        l = l->suivant;
    }
    l->suivant = l2;
}

void semantic_error(const char *error)
{
    fprintf(stderr, "Semantic error at line %d:%d : %s\n", yylineno, yycol, error);
    exit(1);
}

fonction_t *ajouter_fonction(type_t type, const char *nom, liste_t *args, symbole_t *declarations)
{
    int h;
    fonction_t *f;
    fonction_t *precedent;
    fonction_t *nouvelle_fonction;
    h = hash(nom);
    f = fonctions[h];
    precedent = NULL;
    while (f != NULL)
    {
        if (strcmp(f->nom, nom) == 0)
        {
            /* on a trouvé une fonction portant le meme nom */
            if ((f->type == type) && (listes_egales(f->arguments, args)))
                printf("Re-déclaration cohérente de la fonction %s a la ligne %d:%d\n", f->nom, yylineno, yycol);
            else
                printf("Re-déclaration incohérente de la fonction %s a la ligne %d:%d\n", f->nom, yylineno, yycol);
                exit(1);
            return NULL;
        }
        precedent = f;
        f = f->suivant;
    }
    nouvelle_fonction = (fonction_t *)malloc(sizeof(fonction_t));

    if (precedent == NULL)
    {
        fonctions[h] = nouvelle_fonction;
        f = fonctions[h];
    }
    else
    {
        precedent->suivant = nouvelle_fonction;
        f = precedent->suivant;
    }
    f->type = type;
    f->nom = strdup(nom);
    f->arguments = args;
    f->declarations = declarations;
    if (strcmp("EXTERN", nom) != 0) {
        f->local = malloc(sizeof(local));
        memcpy(f->local, local, sizeof(local));
        // printf("FONC NAME : %s\n", f->nom);
        // affiche(f->local);
    }
    // affiche(f->local);

    // affiche(f->local);
    f->suivant = NULL;
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

void afficher_liste(liste_t *liste)
{
    liste_t *next = liste;
    while (next != NULL) {
        printf(" %s (%s)", next->param->nom,
               get_type(next->param->type));
        next = next->suivant;
    }
}

void afficher_symb(symbole_t *declarations) {
    symbole_t *next = declarations;
    printf("Declarations : ");
    while (next != NULL) {
        printf("-> %s (%s)", next->nom, get_type(next->type));
        next = next->suivant;
    }
}

void afficher_fonction(fonction_t *fonction)
{
    if (fonction == NULL) {
        return;
    }
    printf("Fonction: %s\n", fonction->nom);
    printf("Type: %s\n", (fonction->type == _INT) ? "int" : "void");
    printf("Arguments:");
    if (fonction->arguments != NULL)
        afficher_liste(fonction->arguments);
    else
        printf(" aucun");
    printf("\n");
    if (fonction->declarations != NULL) {
        afficher_symb(fonction->declarations);
    }
    else {
        printf("Aucune déclarations\n");
    }
    printf("\n\n");
}

int tab_size(symbole_t *tab) {
    int i = 0;
    symbole_t *q = tab;
    while (q != NULL) {
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

void check_semantic_errors(fonction_t *func) {
    symbole_t **local_declaration = func->local;
    affiche(local_declaration);

}