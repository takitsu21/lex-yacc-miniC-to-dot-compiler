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
	extern node_t *bloc;
	// init();
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
				visualise($2);
				char *dst = strcpy(dst, "digraph mon_programme {\n");

				strcat(dst, $2->code);
				strcat(dst, "node_reste [shape=triangle label=\"...\" style=dotted];\n");
				strcat(dst, "node_main -> node_reste\n");
				strcat(dst, "}");
				printf("%s\n", dst);
				write_file("mytest.dot", dst);
			}
;
liste_declarations	:
		liste_declarations declaration	{

				// insert_next($1, $2);
				// $2->suivant = $1;
				// $$ = $2;
			}
	| {
		// $$ = mk_single_node("LIST_DECL EPSILON");
		// printf("list declarations\n");
	}
;
liste_fonctions	:
		liste_fonctions fonction {
		insert_next($1, $2);
		$$ = $1;

	}
	|   fonction	{
		$$ = $1;
	}
;
declaration	:
		type liste_declarateurs ';' 	{
			// printf("DECLARATION\n");
			// $2->type = $1->type;
			// insert_children($1, $2, NULL, NULL, NULL);
			// printf("ici");

			// $$ = $1;

	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {

			// insert_next($1, $3);
			// $$ = $1;
			// printf("laaa\n");
			}
	|	declarateur 	{ $$ = $1; }
;
declarateur	:
		IDENTIFICATEUR {
				// printf("DECLARATEUR %s\n", $1->nom);
				$$ = $1;
			}
	|	declarateur '[' CONSTANTE ']' {
			$$ = mk_single_node("TAB");
			$$->fils = $1;
		}
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
		$2->type = $1->type;
		$2->fils = $8;
		sprintf($2->code, "node_%s [label=\"%s, %s\" shape=invtrapezium color=blue];", $2->nom, $2->nom, get_type($2->type));
		// $$->code = strdup(src);
		$$ = $2;
		printf("$$->code %s\n", $$->code);



		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			printf("EXTERN %s\n", $3->nom);
		}
;
type	:
		VOID	{ printf("type\n");$$ = create_node("VOID", _VOID); }
	|	INT		{ printf("type\n");$$ = create_node("INT", _INT); }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm	{
				// insert_next($1, $3);
				// $$ = $1;
			}
	| 	parm	{
		// $$ = $1;
		}
;
liste_parms	:
		liste_parms ',' parm	{
				insert_next($1, $3);
				$$ = $1;
			}
	| create_liste_param {
			$$ = $1;
		}
	| {$$ = mk_single_node("LIST PARMS"); }
;
parm	:
		INT IDENTIFICATEUR	{
				$2->type = _INT;
				$$ = $2;
			}
;
liste_instructions :
		liste_instructions instruction {
			insert_next($1, $2);
			$$ = $1;
		}
	| {
		printf("liste instructions empty\n");
		$$ = mk_single_node("LIST_INST");
		}
;
instruction	:
		iteration {printf("before iteration "); $$ = $1;printf("after iteration\n"); }
	|	selection {printf("before selection "); $$ = $1;printf("after selection\n"); }
	|	saut {printf("before saut "); $$ = $1;printf("after saut\n"); }
	|	affectation ';' {
		printf("before inst affectation ");$$ = $1;printf("after inst affectation\n"); }
	|	bloc {printf("bloc ");$$ = $1;printf("after bloc\n");}
	|	appel {printf("appel ");$$ = $1;printf("appel after\n"); }
;
iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction {
			node_t *for_node = mk_single_node("FOR");
			for_node->fils = $3;
			for_node->fils->suivant = $5;
			for_node->fils->suivant->suivant = $7;
			for_node->fils->suivant->suivant->suivant = $9;
			$$ = for_node;
			// print_all_next(for_node->suivant, 0);
			}
	|	WHILE '(' condition ')' instruction {
			node_t *for_node = mk_single_node("WHILE");
			for_node->fils = $3;
			for_node->fils->suivant = $5;
			$$ = for_node;
		}
;
selection	:
		IF '(' condition ')' instruction %prec THEN {
			node_t *if_node = mk_single_node("IF");
			insert_next(if_node, $3);
			insert_next(if_node, $5);
			// if_node->fils = $3;
			// if_node->fils->suivant = $5;
			$$ = if_node;
		}
	|	IF '(' condition ')' instruction ELSE instruction {
			node_t *if_node = mk_single_node("IF");
			insert_next(if_node, $3);
			insert_next(if_node, $5);
			insert_next(if_node, $7);
			// if_node->fils = $3;
			// if_node->fils->suivant = $5;
			// if_node->fils->suivant->suivant = $7;
			$$ = if_node;
		}
	|	SWITCH '(' expression ')' instruction {
		node_t *node_switch = mk_single_node("SWITCH");
		node_switch->fils = $3;
		node_switch->fils->suivant = $5;
		$$ = node_switch; }
	|	CASE CONSTANTE ':' instruction {
		$$ = mk_single_node("CASE"); }
	|	DEFAULT ':' instruction {$$ = mk_single_node("DEFAULT"); }
;
saut	:
		BREAK ';' { $$ = create_node("BREAK", NULL); }
	|	RETURN ';' {
		printf("before return\n");
		$$ = mk_single_node("RETURN");
		printf("after return\n"); }
	|	RETURN expression ';' {
		printf("before return\n");
		$$ = create_node_children(mk_single_node("RETURN"), $2, NULL, NULL, NULL);
	printf("after return\n"); }
;
affectation	:
		variable '=' expression {
			// printf("%s\n", $1->nom);
			printf("VARIABLE 1\n");
			// node_t *node = mk_single_node(":=");

			// printf("%s\n", node->nom);
			printf("VARIABLE 2\n");
			$$ = create_node_children(mk_single_node(":="), $1, $3, NULL, NULL);
			printf("VARIABLE 3\n");
		}
;
bloc	:
		'{' liste_declarations liste_instructions '}' {
			printf("BLOC\n");
			$$ = create_node_children(mk_single_node("BLOC"), $3, NULL, NULL, NULL);

			printf("AFTER BLOC\n");
		}
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';' {
			printf("APPEL \n");
			insert_children($1, $3);
			$$ = $1;
		}
;
variable	:
		IDENTIFICATEUR	{
				$$ = $1;
			}
	|	variable '[' expression ']' {
			$$ = $1;
			printf("variable %s\n", $1->nom);
		}
;
/* TD 5 */
expression :

	'(' expression ')' { $$ = $2; }
	| expression PLUS expression {$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression MOINS expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression DIV expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression MUL expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression RSHIFT expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression LSHIFT expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression BAND expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression BOR expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| MOINS expression %prec MUL { printf("%s\n", $1->nom);$$ = create_node_children($1, $2, NULL, NULL, NULL); }
	| CONSTANTE { $$ = $1;printf("%s\n", $1->nom);  }
	| variable { $$ = $1;printf("%s\n", $1->nom); }
	| IDENTIFICATEUR '(' liste_expressions ')' {
		// $1->suivant = $3;
		printf("id liste_expr");
		insert_children($1, $3);
		$$ = $1;
		}
;
liste_expressions	:
		create_expr_liste { printf("list creation"); $$ = $1; }
	| { printf("list expr eps\n");$$ = create_node("LIST_EXPR", NULL); }
;
create_expr_liste :   // cf mail forum David Fissore
    	create_expr_liste ',' expression {
			printf("create_expr_liste\n");
			$1->suivant = $3;
			$$ = $1; }
    | 	expression { printf("create expression\n");$$ = $1; }
;
condition	:
		NOT '(' condition ')' {
			node_t *node = mk_single_node("NOT");
			$$ = create_node_children(node, $3, NULL, NULL, NULL);
			}
	|	condition binary_rel condition %prec REL {
		$$ = create_node_children($2, $1, $3, NULL, NULL);
		}
	|	'(' condition ')' { $$ = $2; }
	|	expression binary_comp expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
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