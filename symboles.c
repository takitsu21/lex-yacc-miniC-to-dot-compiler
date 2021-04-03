#include "symboles.h"

int hash(char *nom)
{
    int i, r;
    int taille = strlen(nom);
    r = 0;
    for (i = 0; i < taille; i++)
        r = ((r << 8) + nom[i]) % TAILLE;
    return r;
}

void table_reset()
{
    int i;
    for (i = 0; i < TAILLE; i++)
        table[i] = NULL;
}

symbole *inserer(char *nom)
{
    int h;
    symbole *s;
    symbole *precedent;

    h = hash(nom);
    s = table[h];
    precedent = NULL;

    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0)
            return s;
        precedent = s;
        s = s->suivant;
    }
    if (precedent == NULL)
    {
        table[h] = (symbole *)malloc(sizeof(symbole));
        s = table[h];
    }
    else
    {
        precedent->suivant = (symbole *)malloc(sizeof(symbole));
        s = precedent->suivant;
    }

    s->nom = strdup(nom);
    s->suivant = NULL;
    return s;
}

void affiche()
{
    int i = 0;
    symbole *s;
    for (i = 0; i < TAILLE; i++)
    {
        if (table[i] == NULL)
        {
            printf(" orpo table[%d]->NULL\n", i);
        }
        else
        {
            s = table[i];
            printf("table[%d]-> %s ", i, s->nom);
            while (s->suivant != NULL)
            {
                printf("[%s]->", s->nom);
                s = s->suivant;
            }
            printf("NULL\n");
        }
    }
}

void assigne(symbole *table[], const char *var, int value)
{
    int hash_text = hash(var);
    table[hash_text]->nom = strdup(var);
    table[hash_text]->valeur = value;
}

liste_t *creer_liste(param_t p)
{
    liste_t *liste;
    liste = (liste_t *)malloc(sizeof(liste_t));
    assert(liste != NULL);
    liste->param = p;
    liste->suivant = NULL;
    return liste;
}

liste_t *concatener_listes(liste_t *l1, liste_t *l2)
{
    liste_t *l = l1;
    if (l1 == NULL)
        return l2;
    while (l->suivant != NULL)
        l = l->suivant;
    l->suivant = l2;
    return l1;
}

void afficher_liste(liste_t *liste)
{
    liste_t *l;
    for (l = liste; l != NULL; l = l->suivant)
    {
        if (l != liste)
            printf(",");
        printf(" %s (%s)", l->param.nom,
               (l->param.type == _INT) ? "int" : "void");
    }
}

int listes_egales(liste_t *l1, liste_t *l2)
{
    liste_t *liste;
    for (liste = l1; liste != NULL; liste = liste->suivant)
    {
        if ((l2 == NULL) || (l2->param.type != liste->param.type))
            return 0;
        l2 = l2->suivant;
    }
    if (l2 != NULL)
        return 0;
    return 1;
}

fonction_t *ajouter_fonction(type_t type, char *nom, liste_t *args)
{
    int h;
    fonction_t *f;
    fonction_t *precedent;
    fonction_t *nouvelle_fonction;
    h = hash(nom);
    f = table[h];
    precedent = NULL;
    while (f != NULL)
    {
        if (strcmp(f->nom, nom) == 0)
        {
            /* on a trouvé une fonction portant le meme nom */
            if ((f->type == type) && (listes_egales(f->arguments, args)))
                printf("Re-déclaration cohérente de la fonction %s\n", f->nom);
            else
                printf("Re-déclaration incohérente de la fonction %s\n", f->nom);
            return NULL;
        }
        precedent = f;
        f = f->suivant;
    }
    nouvelle_fonction = (fonction_t *)malloc(sizeof(fonction_t));
    assert(nouvelle_fonction != NULL);
    if (precedent == NULL)
    {
        table[h] = nouvelle_fonction;
        f = table[h];
    }
    else
    {
        precedent->suivant = nouvelle_fonction;
        f = precedent->suivant;
    }
    f->type = type;
    f->nom = strdup(nom);
    f->arguments = args;
    f->suivant = NULL;
    return f;
}

param_t *create_param(type_t type) {
    param_t *p = (param_t *)malloc(sizeof(param_t));
    p->type = type;
    p->nom = NULL;
    return p;
}


// int main()
// {
//     // table_reset();
//     // printf("porca paletta");
//     inserer("coco");
//     inserer("coca");
//     inserer("lala");
//     inserer("cola");
//     // affiche();
//     printf("Hello, World!\n");
//     printf("%s", table[1]->nom);
//     return 0;
// }