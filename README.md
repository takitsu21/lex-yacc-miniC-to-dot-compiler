# Projet de compilation

Compilateur miniC vers code intermédiaire dot.

## Différentes façon de tester

⚠️ Tout les fichiers que vous voulez testé doivent être dans le dossier Tests/ si vous utilisez les commandes make ci-dessous.

- Génerer le binary et générer tout les pdf du dossier Tests/ dans pdf-output/ et tout leur .dot respectif dans dot-output/

```make```

- Vous pouvez aussi testé un fichier à la fois, impérativement faire attention que le fichier soit dans le dossier "Tests/".

```make test FILENAME=file.c```

Exemple avec add.c dans le dossier de tests fourni :

```make test FILENAME=add.c```

- Générer le binary du programme et l'utilisé comme suit : ./c2dot < Tests/file.c
Cette commande générera uniquement le fichier test.dot.

```make compile```


Problèmes

- Pas toutes les erreurs sémantiques sont gérés mais une grande partie l'ai (cf. rapport)

- Les erreurs sémantiques des tableaux ne sont pas totalement géré il n'y a que l'accès à la (n-ième case du tableau >= taille du tableau) qui est géré.
Par exemple l'erreur sémantique du code ci-dessous n'est pas géré :

```c
int tab[2][5][3], a[2];

void main() {
    tab[0] = a;
}
```
