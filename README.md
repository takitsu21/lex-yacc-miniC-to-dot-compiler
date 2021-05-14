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

- Les erreurs sémantiques des tableaux ne sont pas totalement géré il n'y a que l'accès à la n >= (taille du tableau) qui est géré exemple :

```c
int tab[1][2][3];

int main() {
    tab[1][2][3][4] = 1;
    return 0;
}
```

Ce code va levé une erreur sémantique.

- Le code ci-dessous ne générera pas d'erreurs sémantique alors qu'il devrait car nous avons un type void et int qui sont comparés mais c'est un appel récursif nous n'avons pas géré ce cas.

```c
void main() {
    if (main() > 0) {
        int b;
    }
}
```
En revanche le code :

```c
void test(int b) {
    test(b);
}

void main(int a) {
    int a;
    if (a < test(a)) {
        a = 5;
    }
}
```

lèvera bien l'erreur sémantique que l'expression est de type void et que a est de type int.