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

void assigne(symbole* table[], const char* var, int value) {
    int hash_text = hash(var);
    table[hash_text]->nom = var;
    table[hash_text]->valeur = value;
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