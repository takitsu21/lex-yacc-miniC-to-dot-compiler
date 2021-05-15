# Compiler

Compilateur C vers code intermédiaire dot

## Différentes façon de tester

- Génerer le binary et générer tout les pdf du dossier Tests/ dans pdf-output/ et tout leur .dot respectif dans dot-output/

```make```

- Générer le binary du programme

```make compile```

- Il faut que les fichiers de tests soit obligatoirement dans le dossier Tests/ sinon le programme ne pourra pas les voir.

```make test FILENAME=file.c```

Exemple avec add.c dans le dossier de tests fourni :

```make test FILENAME=add.c```

## Problèmes

- Pas toutes les erreurs sémantiques sont gérés mais une grande partie l'ai (cf. rapport)

- Les erreurs sémantiques des tableaux ne sont pas totalement géré il n'y a que l'accès à la (n-ième case du tableau >= taille du tableau) qui est géré.
Par exemple l'erreur sémantique du code ci-dessous n'est pas géré :

```c
int tab[2][5][3], a[2];

void main() {
    tab[0] = a;
}
```