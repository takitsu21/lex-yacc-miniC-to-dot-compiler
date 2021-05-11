# Compiler

Compilateur C vers code intermédiaire dot

## Différentes façon de tester
- Générer le binary du programme
`make compile`

- Il faut que les fichiers de tests soit obligatoirement dans le dossier `Tests/` sinon le programme ne pourra pas les voir.
`make test FILENAME=file.c`
Exemple avec add.c dans le dossier de tests fourni :
`make test FILENAME=add.c`

- Génerer le binary et générer tout les pdf du dossier Tests/ dans pdf-output et tout leur .dot respectif dans dot-output/
`make`

## Problèmes

Les tableaux ne sont pas encore gérés concernant les erreurs sémantiques, hors mis cela, il n'y a pas de problème connu à ce jour.
