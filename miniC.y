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
	extern int yycol;
	extern int debugger(const char* s, int token, const char* token_type);
%}


%union {
	int val;
	int type;
	struct _symbole *symbole_ptr;
	struct _liste_t *liste;
	struct _param_t *param;
}

%token<symbole_ptr> IDENTIFICATEUR
%token<val> CONSTANTE
// %token<type> INT VOID

%type <symbole_ptr> declarateur variable appel fonction
%type <val> expression
%type <type> type
%type <param> parm
%type <liste> create_liste_param create_expr_liste

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT INT VOID
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
		type liste_declarateurs ';' 	{printf("DECLARATION TYPE : %d\n", $1); }
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
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
			// printf("FONCTION TYPE : %d\n", $1);
		printf("FONCTION : %s, TYPE : %d", $2->nom, $1);
		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:
		VOID	{ $$ = _VOID; }
	|	INT		{ $$ = _INT; }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm	{
			// $$ = concatener_listes($1, creer_liste($3));
			}
	| 	parm
;
liste_parms	:
		liste_parms ',' parm
	| create_liste_param {
		// printf("liste parms : %s\n", $1->param.type);

		// $$ = creer_liste($1);
		}
	|
;
parm	:
		INT IDENTIFICATEUR	{
			$$->nom = strdup($2->nom);
			printf("int : %s\n", $2->nom);
			}
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
	|	expression binary_op expression %prec OP {
		// $$ = $1 + $3;
	// 	switch ($2) {
	// 		case PLUS:
	// 			$$ = $1 + $3;
	// 			break;
	// 		case MOINS:
	// 			$$ = $1 - $3;
	// 			break;
	// 		case DIV:
	// 			$$ = $1 / $3;
	// 			break;
	// 		case MUL:
	// 			$$ = $1 * $3;
	// 			break;
	// 		case LSHIFT:
	// 			$$ = $1 << $3;
	// 			break;
	// 		case RSHIFT:
	// 			$$ = $1 >> $3;
	// 			break;
	// 		case BAND:
	// 			$$ = $1 & $3;
	// 			break;
	// 		default:
	// 			$$ = $1 | $3;
	// 			break;
	// 	}
	}
	|	MOINS expression	{ $$ = -$2; }
	|	CONSTANTE
	|	variable
	|	IDENTIFICATEUR '(' liste_expressions ')'	{
		printf("%s\n", $1->nom);
		$$ = strdup($1->nom);
		}
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
	fprintf(stderr, "Syntax error at line %d:%d : %s\n", yylineno, yycol, s);
	exit(1);
}

int printd(int i) {
    fprintf(stdout, "%d\n", i);
    return 1;
}

// debugger printer
int debugger(const char* s, int token, const char* token_type) {
	yycol += strlen(s);
	#if VERBOSE
		#if DEBUGGER
			printf("[line %d:%d] [%s] -> %s\n", yylineno, yycol, token_type, s);
		#else
			printf("%s \n", s);
		#endif
	#endif
	return token;
}