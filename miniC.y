%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symboles.h"
	#define DEBUGGER 1
	#define VERBOSE 1
	void yyerror(char *s);
	extern symbole *table[TAILLE];
	extern int printd(int i);
	extern int yylineno;
	extern int debugger(const char* s, int token, const char* token_type);
%}
%union {
	int val;
	int type;
	struct _symbole *symbole_ptr;
}

%token<symbole_ptr> IDENTIFICATEUR
%token<val> CONSTANTE
%token<type> INT VOID

%type <symbole_ptr> declarateur variable appel fonction parm
%type <val> expression
%type <type> type

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme
%%
programme	:
		liste_declarations liste_fonctions
;
liste_declarations	:
		liste_declarations declaration
	|
;
liste_fonctions	:
		liste_fonctions fonction
|               fonction	{printf("[%d] : fonction list\n", yylineno); }
;
declaration	:
		type liste_declarateurs ';' 	{printf("[%d] : type liste_declarateurs\n", yylineno); }
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur
	|	declarateur 	{printf("[%d] : declarateur\n", yylineno); }
;
declarateur	:
		IDENTIFICATEUR
	|	declarateur '[' CONSTANTE ']'
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:
		VOID	{printf("VOID : %s\n", $1); $$ = $1; }
	|	INT		{printf("INT : %s\n", $1); $$ = $1; }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm
	| 	parm
;
liste_parms	:
		liste_parms ',' parm
	| create_liste_param
	|
;
parm	:
		INT IDENTIFICATEUR
;
liste_instructions :
		liste_instructions instruction
	|
;
instruction	:
		iteration
	|	selection
	|	saut
	|	affectation ';'
	|	bloc
	|	appel
;
iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection	:
		IF '(' condition ')' instruction %prec THEN
	|	IF '(' condition ')' instruction ELSE instruction
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut	:
		BREAK ';'
	|	RETURN ';'
	|	RETURN expression ';'
;
affectation	:
		variable '=' expression {
		assigne(table, $1->nom, $3);
		// table[hash($1->nom)]->valeur = $3;
		printf("%s = %d\n", table[hash($1->nom)]->nom, table[hash($1->nom)]->valeur); }
;
bloc	:
		'{' liste_declarations liste_instructions '}'
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:
		IDENTIFICATEUR
	|	variable '[' expression ']'
;
expression	:
		'(' expression ')'		{ $$ = $2; }
	|	expression binary_op expression %prec OP
	|	MOINS expression	{$$ = -$2; }
	|	CONSTANTE
	|	variable
	|	IDENTIFICATEUR '(' liste_expressions ')'
;
liste_expressions	:
		create_expr_liste
	|
;
create_expr_liste :   // cf mail forum David Fissore
    	create_expr_liste ',' expression
    | 	expression
;
condition	:
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:
		PLUS
	|       MOINS
	|	MUL
	|	DIV
	|       LSHIFT
	|       RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:
		LAND
	|	LOR
;
binary_comp	:
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%

/* Analyseur syntaxique */
// int main () {
// 	while (yyparse());
// }

// Gestion des erreurs syntaxique
void yyerror(char *s) {
	fprintf(stderr, "Syntax error at line %d : %s\n", yylineno, s);
	exit(1);
}

int printd(int i) {
    fprintf(stdout, "%d\n", i);
    return 1;
}

// debugger printer
int debugger(const char* s, int token, const char* token_type) {
	#if VERBOSE
		#if DEBUGGER
			printf("[line %d] [%s] -> %s\n", yylineno, token_type, s);
		#else
			printf("%s \n", s);
		#endif
	#endif
	return token;
}