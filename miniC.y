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
	extern char* file_name;
	extern int yycol;
	extern int debugger(const char* s, int token, const char* token_type);
	extern int fun_cursor;
	extern int no_node;
	extern node_t* functions;
	extern node_t *bloc;
	// init();
%}


%union {
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR GEQ LEQ EQ NEQ NOT LAND LOR LT GT

%type <node> fonction declarateur variable appel create_expr_liste create_liste_param liste_declarateurs expression type binary_op binary_comp binary_rel parm programme liste_declarations liste_fonctions declaration affectation condition bloc saut liste_instructions iteration instruction selection liste_expressions liste_parms tableau

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

				node_t *q = $2;
				printf("TYPE : %s\n", get_type(q->type));
				while (q->suivant != NULL) {

					q->fils = create_node_children(mk_single_node("BLOC"), q->fils, NULL, NULL, NULL);
					q = q->suivant;
				}
				q->fils = create_node_children(mk_single_node("BLOC"), q->fils, NULL, NULL, NULL);
				visualise($2);
			}
;
liste_declarations	:
		liste_declarations declaration	{

				// insert_next($1, $2);
				// $2->suivant = $1;
				// $$ = $2;
			}
	| {
		$$ = NULL;
	}
;
liste_fonctions	:
		liste_fonctions fonction {
		// insert_next_brother($1, $2);


		if ($1 == NULL) {
			// node_t *bloc = create_node_children(mk_single_node("BLOC"), $1, NULL, NULL, NULL);
			$1 = $2;
			insert_next_brother($2, $1);
		} else {
			insert_next($1, $2);
		}
		$$ = $1;
	}
	|   fonction	{
		$$ = $1;
	}
;
declaration	:
		type liste_declarateurs ';' 	{
	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {
			insert_next($1, $3);
			$$ = $1;
			}
	|	declarateur 	{ $$ = $1; }
;
declarateur	:
		IDENTIFICATEUR {
				$$ = $1;
			}
	|	declarateur '[' CONSTANTE ']' {

		}
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
			$2->fils = $8;

			$$->type = $1->type;
			$$ = $2;
			$$->is_func = 1;

		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			printf("EXTERN %s\n", $3->nom);
		}
;
type	:
		VOID	{ printf("type\n");$$ = create_node("_VOID", _VOID); }
	|	INT		{ printf("type\n");$$ = create_node("_INT", _INT); }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm	{

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
			if ($1 == NULL) {
				$1 = $2;
			} else {
				insert_next($1, $2);
			}

			$$ = $1;
			printf("inserting list inst\n");
		}
	| {
		$$ = NULL;
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
			node_t *for_node = create_node_children(mk_single_node("FOR"), $3, $5, $7, $9);
			$$ = for_node;
			// print_all_next(for_node->suivant, 0);
			}
	|	WHILE '(' condition ')' instruction {
			node_t *while_node = create_node_children(mk_single_node("IF"), $3, $5, NULL, NULL);
			$$ = while_node;
		}
;
selection	:
		IF '(' condition ')' instruction %prec THEN {
			node_t *if_node = create_node_children(mk_single_node("IF"), $3, $5, NULL, NULL);
			$$ = if_node;
			// $$->fils->suivant = $5;
		}
	|	IF '(' condition ')' instruction ELSE instruction {
			node_t *if_node = create_node_children(mk_single_node("IF"), $3, $5, $7, NULL);
			$$ = if_node;
		}
	|	SWITCH '(' expression ')' instruction {
		printf("SWITCH\n");
			node_t *node_switch = create_node_children(mk_single_node("SWITCH"), $3, $5, NULL, NULL);
			$$ = node_switch;
		}
	|	CASE CONSTANTE ':' instruction {
		printf("case %s\n", $2->nom);
		printf("%s", $2->nom);
		char * case_name = strcpy(case_name, "case%s");
		node_t *inst = create_node_children(mk_single_node("case"), $4, NULL, NULL, NULL);
		$$ = inst;
		}
	| CASE CONSTANTE ':' instruction saut {
		printf("case %s\n", $2->nom);
			node_t *inst = create_node_children(mk_single_node("case"), $4, $5, NULL, NULL);
			$$ = inst;
		}
	|	DEFAULT ':' instruction {
		$$ = create_node_children(mk_single_node("DEFAULT"), $3, NULL, NULL, NULL);
		// $$->suivant = create_node_children(mk_single_node("DEFAULT"), $3, NULL, NULL, NULL);
		}
;
saut	:
		BREAK ';' { $$ = mk_single_node("BREAK"); }
	|	RETURN ';' {
			$$ = mk_single_node("RETURN");
		}
	|	RETURN expression ';' {
			$$ = create_node_children(mk_single_node("RETURN"), $2, NULL, NULL, NULL);
		}
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
			// $$ = create_node_children(mk_single_node("BLOC"), $3, NULL, NULL, NULL);
			$$ = $3;

			printf("AFTER BLOC\n");
		}
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';' {
			insert_children($1, $3);
			$$ = $1;
		}
;
variable	:
		IDENTIFICATEUR	{
				$$ = $1;
			}
	|	tableau {
			$$ = create_node_children(mk_single_node("TAB"), $1, NULL, NULL, NULL);
		}
;
tableau:
	IDENTIFICATEUR { $$ = $1;}
	| tableau '[' expression ']' {
		insert_next($1, $3);
		$$ = $1;
	}
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
	| { printf("list expr eps\n");$$ = mk_single_node("LIST_EXPR"); }
;
create_expr_liste :   // cf mail forum David Fissore
    	create_expr_liste ',' expression {
			insert_next($1, $3);
			$$ = $1;
			}
    | 	expression { printf("create expression\n");$$ = $1; }
;
condition	:
		NOT '(' condition ')' {
			$$ = create_node_children(mk_single_node("NOT"), $3, NULL, NULL, NULL);
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