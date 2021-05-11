%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symboles.h"
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
%}


%union {
	struct _liste_t *params;
	struct _param_t *param;
	struct _symbole_t *symb;
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR GEQ LEQ EQ NEQ NOT LAND LOR LT GT

%type <node> fonction variable appel create_expr_liste expression type binary_op binary_comp binary_rel programme liste_fonctions affectation condition bloc saut liste_instructions iteration instruction selection liste_expressions tableau

%type <symb> liste_declarateurs liste_declarations declarateur declaration tableau_decl

%type <params> liste_parms create_liste_param
%type <param> parm

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
				while (q->suivant != NULL) {
					// if (q->is_func) {
					// 	add_args_to_ts(fonctions[hash(q->nom)]->local, fonctions[hash(q->nom)]->arguments, q->nom);
					// 	afficher_fonction(fonctions[hash(q->nom)]);
					// }
					if (strcmp(q->nom, "EXTERN")) {
						// affiche(fonctions[hash(q->nom)]->local);

						// printf("FUNC NAME : %s %s\n",fonctions[hash(q->nom)]->nom, q->nom);
					}




					check_declared(q->fils, q->nom);
					q->fils = create_node_children(mk_single_node("BLOC"), q->fils, NULL, NULL, NULL);
					verify_return_statements(q->fils, q->type);

					q = q->suivant;
				}
				// if (strcmp(q->nom, "EXTERN")) {
				// 	affiche(fonctions[hash(q->nom)]->local);
				// 	printf("FUNC NAME : %s %s\n",fonctions[hash(q->nom)]->nom, q->nom);
				// }
				check_declared(q->fils, q->nom);
				q->fils = create_node_children(mk_single_node("BLOC"), q->fils, NULL, NULL, NULL);
				verify_return_statements(q->fils, q->type);
				generateDot($2, "test.dot");


			}
;
liste_declarations	:
		liste_declarations declaration	{
				if ($1 == NULL) {
					$1 = $2;
				} else {
					insert_next_symb($1, $2);
				}

				$$ = $1;
			}
	| {
		$$ = NULL;
	}
;
liste_fonctions	:
		liste_fonctions fonction {
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
			$$ = $2;
			$$->type = $1->type;
	}
;
liste_declarateurs	:
		liste_declarateurs ',' declarateur {

			insert_next_symb($1, $3);
			$$ = $1;
		}
	|	declarateur 	{
			$$ = $1;
		}
;
declarateur	:
		IDENTIFICATEUR {
			if (scope == 0) {
				$$ = inserer(global, $1->nom);
			} else {
				$$ = inserer(local, $1->nom);
			}
		}
	|	tableau_decl {
			$$ = $1;
		}
;
tableau_decl:
	IDENTIFICATEUR { $$ = $1;}
	| tableau_decl '[' expression ']' {
		if (scope == 0) {
			$$ = inserer(global, $1->nom);
			// $$ = create_symb($1->nom, &$1->type);
		} else {
			$$ = inserer(local, $1->nom);
			// $$ = create_symb($1->nom, &$1->type);
		}
		insert_next_symb($$, $3);
		// $$ = inserer(local, $1->nom);
		// printf("%s\n", $3->nom);
		// printf("%d\n", local[hash($1->nom)] != NULL);

		// $$ = local[hash($1->nom)];
		// $$ = insert_next_table(local, $$->nom, create_symb($3->nom, _INT));

	}
fonction	:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
			$$->fils = $8;
			$$->nom = $2->nom;
			$$->type = $1->type;
			$$->is_func = 1;
			printf("FUNC NAME : %s\n", $$->nom);
			ajouter_fonction($1->type, $2->nom, $4, $7);
			// add_args_to_ts(fonctions[hash($2->nom)]->local, fonctions[hash($2->nom)]->arguments, $2->nom);
			// affiche(fonctions[hash($2->nom)]->local);
			// printf("FUNC NAME : %s\n",fonctions[hash($2->nom)]->nom);

			table_reset(local);
		}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			ajouter_fonction($2->type, $3->nom, $5, NULL);
			// printf("fonction[hash($3->nom)] = %s\n", fonctions[hash($3->nom)]->nom);
			// afficher_fonction(fonctions[hash($2->nom)]);
			$$ = mk_single_node("EXTERN");
			$$->is_func = 1;
		}
;
type	:
		VOID	{ $$ = create_node("_VOID", _VOID); }
	|	INT		{ $$ = create_node("_INT", _INT); }
;
create_liste_param :	// cf Forum Khaoula Bouhlal
		create_liste_param ',' parm	{
			if ($1 == NULL) {
				$1 = $3;
			} else {
				concatener_listes($1, creer_liste($3));
			}
			$$ = $1;
		}
	| 	parm	{
			$$ = creer_liste($1);
		}
;
liste_parms	:
		create_liste_param	{
			printf("liste params %s\n", $1->param->nom);
			$$ = $1;
			afficher_liste($$);
		}
	| {
		$$ = NULL;
		}
;
parm	:
		INT IDENTIFICATEUR	{
				$$ = create_param(_INT, $2->nom);
				// $2->type = _INT;
				inserer(local, $2->nom);

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
	|	appel {
		// printf("APPEL : %s\n", $1->nom);
		// if (fonctions[hash($1->nom)] == NULL) {
		// 	char *tmp = malloc(sizeof(char));
		// 	sprintf(tmp, "La fonction %s n'a pas encore été déclaré.\n", $1->nom);
		// 	semantic_error(tmp);
		// } else {
			$$ = $1;
		// }
	}
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
			node_t *if_node = create_node_children(mk_single_node("IF"), $3, $5, $7, NULL);
			$$ = if_node;
		}
	|	SWITCH '(' expression ')' instruction {
			node_t *node_switch = create_node_children(mk_single_node("SWITCH"), $3, $5, NULL, NULL);
			$$ = node_switch;
		}
	|	CASE CONSTANTE ':' liste_instructions selection {
			char *tmp = calloc(4 + strlen($2->nom), sizeof(char));
			sprintf(tmp, "CASE %s", $2->nom);
			node_t *inst = create_node_children(mk_single_node(tmp), $4, $5, NULL, NULL);
			// inst->suivant = $5;
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
			// printf("%s\n", $1->nom);
			if (strcmp("TAB", $1->nom) == 0) {
				check_tab($1, $3);
			}
			else if ( (local[hash($1->nom)] != NULL && scope >= local[hash($1->nom)]->scope) || (global[hash($1->nom)] != NULL)) {

			} else {
				char *tmp = malloc(sizeof(char));
				sprintf(tmp, "La variable %s n'a pas encore été déclaré.\n", $1->nom);
				semantic_error(tmp);
			}
			$$ = create_node_children(mk_single_node(":="), $1, $3, NULL, NULL);
		}
;
bloc	:
		'{' liste_declarations liste_instructions '}' {
			$$ = $3;
		}
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';' {
			// check_call_func($1, $3);
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
;
/* TD 5 */
expression :

	'(' expression ')' { $$ = $2; }
	| expression PLUS expression {  $$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression MOINS expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression DIV expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression MUL expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression RSHIFT expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression LSHIFT expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression BAND expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| expression BOR expression { $$ = create_node_children($2, $1, $3, NULL, NULL); }
	| MOINS expression %prec MUL { $$ = create_node_children($1, $2, NULL, NULL, NULL); }
	| CONSTANTE { $$ = $1;  }
	| variable {
			if (strcmp($1->nom, "TAB") == 0) {
				check_tab($1, $1);
			} else {
				if ((local[hash($1->nom)] != NULL && scope >= local[hash($1->nom)]->scope) || (global[hash($1->nom)] != NULL)) {
					$$ = $1;
				} else {
					char *tmp = malloc(sizeof(char));
					sprintf(tmp, "La variable %s n'a pas encore été déclaré\n", $1->nom);
					semantic_error(tmp);
				}
			}
		}
	| IDENTIFICATEUR '(' liste_expressions ')' {
		// check_call_func($1, $3);
		insert_children($1, $3);
		$$ = $1;
	}
;
liste_expressions	:
		create_expr_liste { $$ = $1; }
	| { $$ = NULL; }
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