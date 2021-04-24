%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symboles.h"
	#define DEBUGGER 1
	#define VERBOSE 1
	void yyerror(char *s);
	extern node_t **tree;
	// extern int printd(int i);
	extern int yylineno;
	extern int yycol;
	extern int debugger(const char* s, int token, const char* token_type);
	// node_t* last_node_used;
	init();
%}


%union {
	// int val;
	// char* nom;
	// int type;
	// char *operator;
	// struct _param_t *param;
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR GEQ LEQ EQ NEQ NOT LAND LOR LT GT

%type <node> fonction declarateur variable appel create_expr_liste create_liste_param liste_declarateurs expression type binary_op binary_comp binary_rel parm programme liste_declarations liste_fonctions declaration affectation condition bloc saut liste_instructions iteration instruction selection liste_expressions

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT INT VOID
%token BREAK RETURN
%token EXTERN
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
	| { $$ = create_node("", NULL, NULL, NULL); }
;
liste_fonctions	:
		liste_fonctions fonction {
		if ($2 != NULL) {
			printf("FONCTION NAME : %s\n", $2->nom);
		}
		$$ = mk_node2($2, $1, NULL);
	}
	|   fonction	{
		if ($1 != NULL) {
			printf("FONCTION NAME : %s\n", $1->nom);
		}
		$$ = $1;
	}
;
declaration	:
		type liste_declarateurs ';' 	{
			$$ = create_node(NULL, NULL, NULL, &$1->type);
	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {
			// $$ = concatener_listes($1, creer_liste($3->type));
			$$->left = mk_node2(NULL, $3, NULL);
			}
	|	declarateur 	{ $$ = $1; }
;
declarateur	:
		IDENTIFICATEUR {
			printf("DECLARATEUR %s\n", $1->nom);
			$$ = $1;
			}
	|	declarateur '[' CONSTANTE ']' {
		// table[hash($1->nom)] = $1->nom;
		// printf("%s[%d]\n", $1->nom, $3);
		}
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {

		// printf("FONCTION %s\n", $2->nom);
		node_t* node = malloc(sizeof(node_t));
		node->nom = strdup($2->nom);
		node->type = $1->type;

		$$ = node;


		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
		//printf("FONCTION %s\n", $3->nom);
		}
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
		liste_instructions instruction {$$->left = mk_node($2, $1, NULL); }
	| { $$ = create_node("LIST_INST", NULL, NULL, NULL); }
;
instruction	:
		iteration {$$ = $1; }
	|	selection { $$ = $1; }
	|	saut { $$ = $1; }
	|	affectation ';' {$$ = $1; }
	|	bloc {$$ = $1;}
	|	appel {$$ = $1; }
;
iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction {
			$$ = mk_node_for(mk_for_loop($3, $5, $7, $9));
			}
	|	WHILE '(' condition ')' instruction {$$ = mk_node($3, "WHILE", $5); }
;
selection	:
		IF '(' condition ')' instruction %prec THEN { $$ = mk_node_if(mk_if_cond($3, $5, NULL)); }
	|	IF '(' condition ')' instruction ELSE instruction { $$ = mk_node_if(mk_if_cond($3, $5, $7)); }
	|	SWITCH '(' expression ')' instruction { $$ = mk_node(NULL, "SWITCH", NULL); }
	|	CASE CONSTANTE ':' instruction { $$ = mk_node($4, $2->nom, NULL); }
	|	DEFAULT ':' instruction {$$ = mk_node(NULL, "DEFAULT", $3); }
;
saut	:
		BREAK ';' { $$ = mk_node(NULL, "BREAK", NULL); }
	|	RETURN ';' {$$ = mk_node(NULL, "RETURN", NULL); }
	|	RETURN expression ';' { $$ = mk_node($2, "RETURN", NULL); }
;
affectation	:
		variable '=' expression {
			printf("VARIABLE : %s\n", $1->nom);
			$$ = mk_node($1, "=", $3);
		}
;
bloc	:
		'{' liste_declarations liste_instructions '}' {
			$$ = mk_node($2, "BLOC", $3);
		}
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';' { printf("APPEL %s\n", $1->nom); }
;
variable	:
		IDENTIFICATEUR	{ $$ = $1; }
	|	variable '[' expression ']' { $$->left = mk_node($1, "VARIABLE", NULL); }
;
expression	:
		'(' expression ')'		{ $$->right = $2; }
	|	expression binary_op expression %prec OP {
		node_t *node = mk_node2($1, $2, $3);
		$$ = node;
	}
	|	MOINS expression	{
		printf("MOINS %s%s\n", $1->nom, $2->nom);

		// node_t* parent_node = create_node(strdup($2->nom), NULL, NULL, NULL);
		$1->left = $2;
		$$ = $1;
		}
	|	CONSTANTE	{ $$ = $1; }
	|	variable	{
		printf("VARIABLE %s\n", $1->nom);
			$$ = $1;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')' {
			// printf("%s\n", $1->nom);
			$$ = mk_node2($3, $1, NULL);
		}
;
liste_expressions	:
		create_expr_liste { $$ = mk_node(NULL, $1, NULL); }
	| {$$ = create_node("LIST_EXPR", NULL, NULL, NULL); }
;
create_expr_liste :   // cf mail forum David Fissore
    	create_expr_liste ',' expression {$$->right = mk_node2($3, $1, NULL); }
    | 	expression { $$->left = $1; }
;
condition	:
		NOT '(' condition ')' { $$->left = mk_node($3, "NOT", NULL); }
	|	condition binary_rel condition %prec REL { $$->right = mk_node($1, $2->nom, $3); }
	|	'(' condition ')' { $$->left = $2; }
	|	expression binary_comp expression { $$ = mk_node2($1, $2, $3); }
;
binary_op	:
		PLUS	{ $$ = $1; }
	|       MOINS	{ $$ = $1; }
	|	MUL	{ $$ = $1; }
	|	DIV	{ $$ = $1; }
	|       LSHIFT	{ $$ = $1; }
	|       RSHIFT	{$$ = $1; }
	|	BAND	{$$ = $1; }
	|	BOR	{$$ = $1; }
;
binary_rel	:
		LAND	{ $$ = $1; }
	|	LOR	{ $$ = $1; }
;
binary_comp	:
		LT	{ $$ = $1; }
	|	GT	{ $$ = $1; }
	|	GEQ	{ $$ = $1; }
	|	LEQ	{ $$ = $1; }
	|	EQ	{ $$ = $1; }
	|	NEQ	{ $$ = $1; }
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