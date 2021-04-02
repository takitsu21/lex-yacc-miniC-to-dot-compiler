# TODO

- [X]  Commencez par tester votre analyseur lexical en premier lieu, et vérifiez que tous les programmes tests
fournis passent correctement (à savoir que les tokens sont correctement analysés par votre analyseur
lexical). Vérifiez sa robustesse en modifiant les programmes tests pour provoquer des erreurs lexicales :
introduisez des caractères interdits, des noms de variables incorrects, etc.

- [X] Une fois que vous êtes sûrs que votre analyseur lexical fonctionne correctement, vérifiez que votre
parseur (analyseur lexico-syntaxique) fonctionne sur tous les programmes tests. Vérifiez sa robustesse
en modifiant les programmes tests pour provoquer des erreurs syntaxiques.

- [ ] Une fois que vous estimez que votre parseur est fiable, commencez à introduire des routines sémantiques
yacc qui affichent des messages appropriés durant la compilation afin de tester que les routines
sémantiques s’exécutent correctement. Ce sera le squelette de votre traduction dirigée par la syntaxe,
que vous devrez compléter pour la génération de code.

- [ ] Attention, en langage C, contrairement à d’autres langages, les chaines de caractères doivent être allouées
en mémoire explicitement. Si une routines sémantique de yacc accède à une chaine de caractères
non allouée en mémoire, votre compilateur plantera.