#include "symboles.h"

// int hash(char *nom)
// {
//     int i, r;
//     int taille = strlen(nom);
//     r = 0;
//     for (i = 0; i < taille; i++)
//         r = ((r << 8) + nom[i]) % TAILLE;
//     return r;
// }

// void table_reset()
// {
//     int i;
//     for (i = 0; i < TAILLE; i++)
//         table[i] = NULL;
// }

// symbole *inserer(char *nom)
// {
//     int h;
//     symbole *s;
//     symbole *precedent;

//     h = hash(nom);
//     s = table[h];
//     precedent = NULL;

//     while (s != NULL)
//     {
//         if (strcmp(s->nom, nom) == 0)
//             return s;
//         precedent = s;
//         s = s->suivant;
//     }
//     if (precedent == NULL)
//     {
//         table[h] = (symbole *)malloc(sizeof(symbole));
//         s = table[h];
//     }
//     else
//     {
//         precedent->suivant = (symbole *)malloc(sizeof(symbole));
//         s = precedent->suivant;
//     }

//     s->nom = strdup(nom);
//     s->suivant = NULL;
//     return s;
// }

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

// void assigne(symbole *table[], const char *var, int value)
// {
//     int hash_text = hash(var);
//     table[hash_text]->nom = strdup(var);
//     table[hash_text]->valeur = value;
// }

// liste_t *creer_liste(param_t p)
// {
//     liste_t *liste;
//     liste = (liste_t *)malloc(sizeof(liste_t));
//     // assert(liste != NULL);
//     liste->param = p;
//     liste->suivant = NULL;
//     return liste;
// }

// liste_t *concatener_listes(liste_t *l1, liste_t *l2)
// {
//     liste_t *l = l1;
//     if (l1 == NULL)
//         return l2;
//     while (l->suivant != NULL)
//         l = l->suivant;
//     l->suivant = l2;
//     return l1;
// }

// void afficher_liste(liste_t *liste)
// {
//     liste_t *l;
//     for (l = liste; l != NULL; l = l->suivant)
//     {
//         if (l != liste)
//             printf(",");
//         printf(" %s (%s)", l->param.nom,
//                (l->param.type == _INT) ? "int" : "void");
//     }
// }

// int listes_egales(liste_t *l1, liste_t *l2)
// {
//     liste_t *liste;
//     for (liste = l1; liste != NULL; liste = liste->suivant)
//     {
//         if ((l2 == NULL) || (l2->param.type != liste->param.type))
//             return 0;
//         l2 = l2->suivant;
//     }
//     if (l2 != NULL)
//         return 0;
//     return 1;
// }

// fonction_t *ajouter_fonction(type_t type, char *nom, liste_t *args)
// {
//     int h;
//     fonction_t *f;
//     fonction_t *precedent;
//     fonction_t *nouvelle_fonction;
//     h = hash(nom);
//     f = table[h];
//     precedent = NULL;
//     while (f != NULL)
//     {
//         if (strcmp(f->nom, nom) == 0)
//         {
//             /* on a trouvé une fonction portant le meme nom */
//             if ((f->type == type) && (listes_egales(f->arguments, args)))
//                 printf("Re-déclaration cohérente de la fonction %s\n", f->nom);
//             else
//                 printf("Re-déclaration incohérente de la fonction %s\n", f->nom);
//             return NULL;
//         }
//         precedent = f;
//         f = f->suivant;
//     }
//     nouvelle_fonction = (fonction_t *)malloc(sizeof(fonction_t));
//     assert(nouvelle_fonction != NULL);
//     if (precedent == NULL)
//     {
//         table[h] = nouvelle_fonction;
//         f = table[h];
//     }
//     else
//     {
//         precedent->suivant = nouvelle_fonction;
//         f = precedent->suivant;
//     }
//     f->type = type;
//     f->nom = strdup(nom);
//     f->arguments = args;
//     f->suivant = NULL;
//     return f;
// }

// param_t *create_param(type_t type) {
//     param_t *p = (param_t *)malloc(sizeof(param_t));
//     p->type = type;
//     p->nom = NULL;
//     return p;
// }

node_t *create_node(const char* nom, int val, void *bt, void* type) {
    node_t *node = (node_t*)malloc(sizeof(node_t));
    node->nom = nom;
    node->val = val;
    node->bt = (bloc_type_t)bt;
    node->type = (type_t)type;
    node->left = NULL;
    node->right = NULL;
    // show_node(node);
    return node;
}

// void show_node(node_t **node) {
//     if (node->suivant != NULL) {
//         printf("NODE CREATED : %s | suivant->%s\n", node->nom, node->suivant->nom);
//     } else {
//         printf("NODE CREATED : %s | suivant->NULL\n", node->nom);
//     }
// }

void insert_to_tree(node_t * node, int cursor) {
    tree[cursor] = node;
}

void insert_next_node(node_t* src_node, node_t *dst_node) {
    node_t *next;
    while ((next = src_node->left) != NULL);
    next->left = dst_node;
}

node_t *mk_node2(node_t *L, node_t *P, node_t *R) {
    P->right = R;
    P->left = L;
    P->for_loop = NULL;
    P->if_cond = NULL;
    debug_node(P);
    return P;
}

node_t *mk_node(node_t *L, const char *parent_name, node_t *R) {
    node_t *node = malloc(sizeof(node_t));
    node->nom = strdup(parent_name);
    node->right = R;
    node->left = L;
    node->for_loop = NULL;
    node->if_cond = NULL;
    debug_node(node);
    return node;
}

node_for_t *mk_for_loop(node_t *init, node_t *cond, node_t *post_cond, node_t *corp) {
    node_for_t *for_loop = (node_for_t*)malloc(sizeof(node_for_t));
    for_loop->init = init;
    for_loop->cond = cond;
    for_loop->post_cond = post_cond;
    for_loop->corp = corp;
    return for_loop;
}

node_if_t *mk_if_cond(node_t *cond, node_t *then, node_t *_else) {
    node_if_t *if_cond = (node_if_t*)malloc(sizeof(node_if_t));
    if_cond->cond = cond;
    if_cond->then = then;
    if_cond->_else = _else;
    return if_cond;
}

node_t *mk_node_if(node_if_t *if_cond) {
    node_t *node = malloc(sizeof(node_t));
    node->nom = "IF";
    node->if_cond = if_cond;
    return node;
}

node_t *mk_node_for(node_for_t *for_loop) {
    node_t *node = malloc(sizeof(node_t));
    node->nom = "FOR";
    node->right = NULL;
    node->left = NULL;
    node->bt = _FOR;
    node->for_loop = for_loop;
    return node;
}

void debug_node(node_t *P) {
    printf("GAUCHE : %s\n", P->left != NULL ? P->left->nom : "NULL");
    printf("PARENT : %s\n", P->nom != NULL ? P->nom : "NULL");
    printf("DROITE : %s\n", P->right != NULL ? P->right->nom : "NULL");
}

void insert_node(node_t *node, char* nom, int cursor) {
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

void init() {
    tree = (node_t**)calloc(100, sizeof(node_t));
}