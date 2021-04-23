%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symboles.h"
	#define DEBUGGER 1
	#define VERBOSE 1
	void yyerror(char *s);
	extern node_t ***tree;
	// extern int printd(int i);
	extern int yylineno;
	extern int yycol;
	extern int debugger(const char* s, int token, const char* token_type);
	// node_t* last_node_used;
	init();
%}


%union {
	int val;
	// char* nom;
	// int type;
	char *operator;
	// struct _param_t *param;
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE
%token PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR

%type <node> fonction declarateur variable appel create_expr_liste create_liste_param liste_declarateurs expression type binary_op binary_comp binary_rel parm programme liste_declarations liste_fonctions declaration affectation

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT INT VOID
%token BREAK RETURN LAND LOR LT GT
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
		liste_declarations liste_fonctions {

			printf("PROGRAMME END\n");
			// tree[0] = $1;
			// $$->declarations = $1; $$->fonctions = $2;
			// code gen ?
			// $$->declarations = creer_liste($1);
			// $$->fonctions = creer_liste($2);
			 }
;
liste_declarations	:
		liste_declarations declaration	{
			// $$ = concatener_listes($1, creer_liste($2));
			// printf("LISTE DECLARATIONS %s\n", $1);
				// $1->suivant[1] = $1;
			}
	|
;
liste_fonctions	:
		liste_fonctions fonction
|               fonction	{ printf("FONCTION NAME : %s\n", $1); }
;
declaration	:
		type liste_declarateurs ';' 	{
			$$ = mk_node(NULL, NULL, NULL, $1->type);
	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {
			// $$ = concatener_listes($1, creer_liste($3->type));
			}
	|	declarateur 	{ $$ = $1; }
;
declarateur	:
		IDENTIFICATEUR {
			printf("%s\n", $1->nom);
			$$ = $1;
			}
	|	declarateur '[' CONSTANTE ']' {
		// table[hash($1->nom)] = $1->nom;
		// printf("%s[%d]\n", $1->nom, $3);
		}
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {

		printf("FONCTION %s\n", $2->nom);
		node_t* node = malloc(sizeof(node_t));
		node->nom = strdup($2->nom);
		// node->type = $1->type;

		$$ = node;


		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' { printf("FONCTION %s\n", $3->nom); }
;
type	:
		VOID	{ $$ = create_node(NULL, NULL, NULL, _VOID); }
	|	INT		{ $$ = create_node(NULL, NULL, NULL, _INT); }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm	{
			// $$ = concatener_listes($1, (creer_liste((param_t)$3));
			// printf("PARM %d\n", $3->nom);
			// $$ = creer_liste($3);
			// $$ = concatener_listes($1, creer_liste(*$3));
			}
	| 	parm	{ $$ = $1; }
;
liste_parms	:
		liste_parms ',' parm	{
			// $$ = concatener_listes($1, creer_liste(*$3));
			// printf("PARM %d\n", $3->type);
			}
	| create_liste_param {
		// printf("liste parms : %s\n", $1->param.nom);

		// $$ = creer_liste($1->param);
		// printf("LISTE_PARMS %s : %d\n", $$->param.nom, $$->param.type);
		}
	|
;
parm	:
		INT IDENTIFICATEUR	{
			// $$->nom = strdup($2->nom);
			// $$->type = _INT;
			// $$ = create_node(strdup($1), NULL, NULL, _INT);
			$$->type = _INT;

			// printf("int : %s\n", $2->nom);
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
			$$ = mk_node($1, "=", $3);
		}
;
bloc	:
		'{' liste_declarations liste_instructions '}'
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';' { printf("APPEL %s\n", $1->nom); }
;
variable	:
		IDENTIFICATEUR	{ $$ = $1; }
	|	variable '[' expression ']'
;
expression	:
		'(' expression ')'		{ $$ = $2; }
	|	expression binary_op expression %prec OP {
		// node_t *node = malloc(sizeof(node_t));
		// node_t **suivant = (node_t**)calloc(3, sizeof(node_t));
		// suivant[0] = $1;
		// printf("*$1 : %s | *$3 : %s\n", $1->nom, $3->nom);
		// suivant[1] = $3;
		// node->nom = strdup($2->nom);
		// node->suivant = suivant;
		// printf("GAUCHE : %s\n", suivant[0]->nom);
		// printf("PARENT : %s\n", node->nom);
		// printf("DROITE : %s\n", suivant[1]->nom);
		// last_node_used = node;
		$$ = mk_node($1, $2->nom, $3);
	}
	|	MOINS expression	{
		printf("-%s\n", $2->nom);
		// $1->nom = strcat()
		node_t* parent_node = create_node("-", NULL, NULL, NULL);
		node_t **child_nodes = calloc(3, sizeof(node_t));

		child_nodes[0] = $2;

		$$ = parent_node;
		}
	|	CONSTANTE	{ $$ = $1; }
	|	variable	{ printf("VARIABLE %s\n", $1->nom);
			$$ = $1;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')' {
			printf("%s\n", $1->nom);
			$$ = $1;
		}
;
liste_expressions	:
		create_expr_liste { /* $$ = creer_liste($1); */ }
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
		PLUS	{ $$ = create_node("+", NULL, NULL, NULL); }
	|       MOINS	{ $$ = create_node("-", NULL, NULL, NULL); }
	|	MUL	{ $$ = create_node("*", NULL, NULL, NULL); }
	|	DIV	{ $$ = create_node("/", NULL, NULL, NULL); }
	|       LSHIFT	{ $$ = create_node("<<", NULL, NULL, NULL); }
	|       RSHIFT	{$$ = create_node(">>", NULL, NULL, NULL); }
	|	BAND	{$$ = create_node("&", NULL, NULL, NULL); }
	|	BOR	{$$ = create_node("|", NULL, NULL, NULL); }
;
binary_rel	:
		LAND	{ $$ = create_node("&&", NULL, NULL, NULL); }
	|	LOR	{ $$ = create_node("||", NULL, NULL, NULL); }
;
binary_comp	:
		LT	{ $$ = create_node("<", NULL, NULL, NULL); }
	|	GT	{ $$ = create_node(">", NULL, NULL, NULL); }
	|	GEQ	{ $$ = create_node(">=", NULL, NULL, NULL); }
	|	LEQ	{ $$ = create_node("<=", NULL, NULL, NULL); }
	|	EQ	{ $$ = create_node("==", NULL, NULL, NULL); }
	|	NEQ	{ $$ = create_node("!=", NULL, NULL, NULL); }
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