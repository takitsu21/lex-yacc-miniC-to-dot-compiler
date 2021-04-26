%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symboles.h"
	#define DEBUGGER 0
	#define VERBOSE 0
	void yyerror(char *s);
	extern node_t **tree;
	// extern int printd(int i);
	extern int yylineno;
	extern int yycol;
	extern int debugger(const char* s, int token, const char* token_type);
	extern int fun_cursor;
	extern node_t* functions;
	init();
%}


%union {
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR GEQ LEQ EQ NEQ NOT LAND LOR LT GT

%type <node> fonction declarateur variable appel create_expr_liste create_liste_param liste_declarateurs expression type binary_op binary_comp binary_rel parm programme liste_declarations liste_fonctions declaration affectation condition bloc saut liste_instructions iteration instruction selection liste_expressions liste_parms

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
				// display($1, 0);
				// display($2, 0);

				node_t *next;
				while ((next = functions->suivant) != NULL) {
					display(next, 0);
				}


			}
;
liste_declarations	:
		liste_declarations declaration	{

				$$ = mk_node($2, "LIST DECL", NULL);

				printf("list declarations\n");
			}
	| { $$ = create_node("LIST_DECL EPSILON", NULL, NULL, NULL);printf("list declarations\n"); }
;
liste_fonctions	:
		liste_fonctions fonction {
		if ($2 != NULL) {
			printf("FONCTION NAME : %s\n", $2->nom);
			functions->suivant = $2;
		}


		$$ = mk_node($2, $2->nom, NULL);


	}
	|   fonction	{
		if ($1 != NULL) {
			printf("FONCTION NAME : %s\n", $1->nom);
		}
		// functions->suivant = $1;

		// tree[fun_cursor] = $1;
		// printf("tree fun cursor %s\n", tree[fun_cursor]);
		// fun_cursor++;
		$$ = $1;
		// functions->suivant = $$;

	}
;
declaration	:
		type liste_declarateurs ';' 	{
			// printf("DECLARATION %s\n", $2->nom);
			printf("DECLARATION\n");
			// $$ = mk_node2($2, create_node("INT", NULL, NULL, NULL), NULL);
			// $$ = mk_node2($2, $1, NULL);
			$$ = $1;
	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {
			// printf("list declarateurs %s\n", $3->nom);

				// $$ = mk_node(NULL, $1, $3);
				$$ = $3;
				printf("declarateur %s\n", $3->nom);
				// display($$, 0);
				// printf("left %s\n", $$->nom);
			}
	|	declarateur 	{ printf("declarateur %s\n", $1->nom);$$ = $1; }
;
declarateur	:
		IDENTIFICATEUR {
			printf("DECLARATEUR %s\n", $1->nom);
			$$ = $1;
			}
	|	declarateur '[' CONSTANTE ']' {
			$$ = create_node("TAB", NULL, NULL, NULL);
		}
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {


		// printf("FONCTION %s\n", $2->nom);
		// node_t* node = malloc(sizeof(node_t));
		// node->nom = strdup($2->nom);
		// node->type = $1->type;
		node_t *node = create_node($2->nom, NULL, NULL, &$1->type);
		$$ = mk_node2($7, node, $8);

		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			printf("EXTERN %s\n", $3->nom);
		}
;
type	:
		VOID	{ printf("type\n");$$ = create_node("VOID", NULL, NULL, _VOID); }
	|	INT		{ printf("type\n");$$ = create_node("INT", NULL, NULL, _INT); }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm	{
				$$ = mk_node2(NULL, "liste_param", $3);
			}
	| 	parm	{ $$ = $1; }
;
liste_parms	:
		liste_parms ',' parm	{
				printf("list_parms\n");
				$$ = mk_node2(NULL, "list_parms", $3);
			}
	| create_liste_param {
			$$ = mk_node(NULL, $1, NULL);
		}
	| {$$ = mk_node(NULL, "EMPTY LIST", NULL); }
;
parm	:
		INT IDENTIFICATEUR	{
				$2->type = _INT;
				$$ = $2;
			}
;
liste_instructions :
		liste_instructions instruction {
			printf("list instr %s \n", $2->nom);
			$$ = mk_node($2, "list_instr", NULL);
		}
	| {
		printf("list instr  eps \n");
		$$ = create_node("LIST_INST", NULL, NULL, NULL);
		printf("$$ %s\n", $$->nom);
		}
;
instruction	:
		iteration {printf("iteration\n"); $$ = $1; }
	|	selection {printf("selection\n"); $$ = $1; }
	|	saut {printf("saut\n"); $$ = $1; }
	|	affectation ';' {printf("inst affectation\n");$$ = $1; }
	|	bloc {printf("bloc\n");$$ = $1;}
	|	appel {printf("appel\n");$$ = $1; }
;
iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction {
			node_t *for_node = mk_node(NULL, "FOR", NULL);
			for_node->suivant = $3;
			for_node->suivant->suivant = $5;
			for_node->suivant->suivant->suivant = $7;
			for_node->suivant->suivant->suivant->suivant = $9;
			$$ = for_node;
			}
	|	WHILE '(' condition ')' instruction {$$ = mk_node($3, "WHILE", $5); }
;
selection	:
		IF '(' condition ')' instruction %prec THEN { $$ = create_node("IF", NULL, NULL, NULL); }
	|	IF '(' condition ')' instruction ELSE instruction { $$ = create_node("IF", NULL, NULL, NULL); }
	|	SWITCH '(' expression ')' instruction { $$ = mk_node($3, "SWITCH", $5); }
	|	CASE CONSTANTE ':' instruction { $$ = mk_node($2, "CASE", $4); }
	|	DEFAULT ':' instruction {$$ = mk_node($3, "DEFAULT", NULL); }
;
saut	:
		BREAK ';' { $$ = mk_node(NULL, "BREAK", NULL); }
	|	RETURN ';' {$$ = mk_node(NULL, "RETURN", NULL); }
	|	RETURN expression ';' { $$ = mk_node($2, "RETURN", NULL); }
;
affectation	:
		variable '=' expression {
			$$ = mk_node($1, ":=", $3);
			// display($$, 0);
		}
;
bloc	:
		'{' liste_declarations liste_instructions '}' {
			printf("BLOC\n");
			$$ = mk_node($2, "BLOC", $3);
		}
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';' {
			printf("APPEL \n");
			$$ = mk_node2($3, $1, NULL); }
;
variable	:
		IDENTIFICATEUR	{ $$ = $1; }
	|	variable '[' expression ']' { $$ = mk_node($3, "TAB", NULL); }
;
expression	:
		'(' expression ')'		{ $$ = $2; }
	|	expression binary_op expression %prec OP {
		node_t *node3 = mk_node2($1, $2, $3);
		$$ = mk_node2($1, $2, $3);;
	}
	|	MOINS expression	{
			$$ = mk_node2($2, $1, NULL);
		}
	|	CONSTANTE	{ $$ = $1; }
	|	variable	{
			$$ = $1;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')' {
			printf("EXPR ID %s\n", $1->nom);
			$$ = mk_node2($1, $3, NULL);
		}
;
liste_expressions	:
		create_expr_liste { $$ = $1; }
	| { $$ = create_node("LIST_EXPR", NULL, NULL, NULL); }
;
create_expr_liste :   // cf mail forum David Fissore
    	create_expr_liste ',' expression {
			$$ = mk_node($3, "create_expr_liste", NULL); }
    | 	expression { $$ = $1; }
;
condition	:
		NOT '(' condition ')' { $$ = mk_node($3, "NOT", NULL); }
	|	condition binary_rel condition %prec REL { $$ = mk_node2($1, $2, $3); }
	|	'(' condition ')' { $$ = $2; }
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