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

Les erreurs sémantiques des tableaux ne sont pas totalement géré il n'y a que l'accès à la n >= (taille du tableau) qui est géré exemple :

```c
int tab[1][2][3];

int main() {
    tab[1][2][3][4] = 1;
    return 0;
}
```
Ce code va levé une erreur sémantique.
