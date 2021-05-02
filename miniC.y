%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symboles.h"
	#include "table.h"
	#define DEBUGGER 0
	#define VERBOSE 0
	void yyerror(char *s);
	// extern int printd(int i);
	extern int yylineno;
	extern char* file_name;
	extern int yycol;
	extern int debugger(const char* s, int token, const char* token_type);
	extern int no_node;
	extern int scope;
	// init();
%}


%union {
	struct _symbole_t *symb;
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR GEQ LEQ EQ NEQ NOT LAND LOR LT GT

%type <node> fonction variable appel create_expr_liste create_liste_param expression type binary_op binary_comp binary_rel programme liste_fonctions affectation condition bloc saut liste_instructions iteration instruction selection liste_expressions tableau

%type <symb> liste_declarateurs liste_declarations declarateur declaration liste_parms parm

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
				// visualise($2);
				generateDot($2, "test.dot");
				// printf("LIST DECL %s\n", $1->nom);
				affiche();
				// printf("%s\n", file_name);

			}
;
liste_declarations	:
		liste_declarations declaration	{

				// insert_next($1, $2);
				// $2->suivant = $1;
				// $$ = $2;
				// if ($1 == NULL) {
				// 	$1 = $2;
				// } else {
				// 	insert_next_symb($1, $2);
				// }
				$$ = inserer($2->nom);
			}
	| {
		$$ = NULL;
	}
;
liste_fonctions	:
		liste_fonctions fonction {
		// insert_next_brother($1, $2);

		if ($1 == NULL) {
			$1 = $2;
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
			// table[hash()]
			$$ = $2;
			$$->type = $1->type;
			printf("DECLARATION %s\n", $$->nom);

	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {

			if ($1 == NULL) {
				$1 = $3;
			} else {
				insert_next_symb($1, $3);
			}

			// table[hash($3->nom)] = $1;
			// inserer($3->nom);
			$$ = $1;
			}
	|	declarateur 	{
		$$ = $1;
		// inserer($1->nom);
		// inserer($1->nom);
		}
;
declarateur	:
		IDENTIFICATEUR {
				$$ = inserer($1->nom);
			}
	|	declarateur '[' CONSTANTE ']' {
			$$ = inserer($1->nom);
			table[hash($1->nom)]->constante = $3->nom;
			// table[hash($1->nom)]->constante =  strdup($3->nom);
			// $$ = create_symb($1->nom, NULL);
			$$->constante = $3->nom;
		}
;
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
			// $2->fils = $8;
			$$->fils = $8;
			$$->nom = $2->nom;
			$$->type = $1->type;
			$$->is_func = 1;
			// table_reset();

		}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			// $$ = $3;
			inserer($3->nom);
			table[hash($3->nom)]->type = $2->type;
			printf("table[hash($3->nom)] = %s\n", table[hash($3->nom)]->nom);
			$$ = mk_single_node("EXTERN");
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
				// if ($1 == NULL) {
				// 	$1 = $3;
				// } else {
				// 	insert_next_symb($1, $3);
				// }
				// $$ = $3;
				// $$ = inserer($3->nom);
			}
	| create_liste_param {
			// $$ = $1;
			// $$ = $1;
		}
	| {
		// $$ = NULL;
		// $$ = NULL;
		}
;
parm	:
		INT IDENTIFICATEUR	{
				// $2->type = _INT;
				// $$ = $2;
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
		}
	| {
		$$ = NULL;
		}
;
instruction	:
		iteration {$$ = $1; }
	|	selection {$$ = $1;}
	|	saut {$$ = $1; }
	|	affectation ';' {$$ = $1; }
	|	bloc {$$ = $1;}
	|	appel {$$ = $1;}
;
iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction {
			$$ = create_node_children(mk_single_node("FOR"), $3, $5, $7, $9);
			}
	|	WHILE '(' condition ')' instruction {
			$$ = create_node_children(mk_single_node("WHILE"), $3, $5, NULL, NULL);
		}
;
selection	:
		IF '(' condition ')' instruction %prec THEN {
			$$ = create_node_children(mk_single_node("IF"), $3, $5, NULL, NULL);
		}
	|	IF '(' condition ')' instruction ELSE instruction {
			node_t *if_node = create_node_children(mk_single_node("IF"), $3, $5, NULL, NULL);
			$$ = if_node;
			$$->suivant = $7;
		}
	|	SWITCH '(' expression ')' instruction {
			node_t *node_switch = create_node_children(mk_single_node("SWITCH"), $3, $5, NULL, NULL);
			$$ = node_switch;
		}
	|	CASE CONSTANTE ':' liste_instructions selection {
			char *tmp = calloc(4 + strlen($2->nom), sizeof(char));
			sprintf(tmp, "CASE %s", $2->nom);
			node_t *inst = create_node_children(mk_single_node(tmp), $4, NULL, NULL, NULL);
			inst->suivant = $5;
			$$ = inst;
		}

	|	DEFAULT ':' instruction {
			$$ = create_node_children(mk_single_node("DEFAULT"), $3, NULL, NULL, NULL);
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
			if (table[hash($1->nom)] != NULL && scope >= table[hash($1->nom)]->scope) {
				$$ = create_node_children(mk_single_node(":="), $1, $3, NULL, NULL);
			} else {
				char *tmp = malloc(sizeof(char));
				sprintf(tmp, "La variable %s n'a pas encore été délcaré\n", $1->nom);
				semantic_error(tmp);
			}
		}
;
bloc	:
		'{' liste_declarations liste_instructions '}' {
			// $$ = create_node_children(mk_single_node("BLOC"), $3, NULL, NULL, NULL);
			$$ = $3;
			// $$->suivant = $3;
			// table[hash($2->nom)] = $2;
			// scope++;
			printf("SCOPE : %d\n", scope);

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
	| { printf("list expr eps\n");$$ = NULL; }
;
create_expr_liste :   // cf mail forum David Fissore
    	create_expr_liste ',' expression {
			if ($1 == NULL) {
				$1 = $3;
			} else {
				insert_next($1, $3);
			}
			$$ = $1;
			}
    | 	expression { $$ = $1; }
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