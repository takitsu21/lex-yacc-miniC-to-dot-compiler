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
	int tab_dimension = 0;
%}


%union {
	struct _liste_t *params;
	struct _param_t *param;
	struct _symbole_t *symb;
	struct _node_t *node;
}

%token <node> IDENTIFICATEUR CONSTANTE PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR GEQ LEQ EQ NEQ NOT LAND LOR LT GT

%type <node> fonction variable appel create_expr_liste expression type binary_comp binary_rel programme liste_fonctions affectation condition bloc saut liste_instructions iteration instruction selection liste_expressions tableau

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
%left REL
%start programme
%%
programme	:
		liste_declarations liste_fonctions {
				node_t* programme = create_node_children(mk_single_node("Programme"), $2, NULL, NULL, NULL);
				while ($2 != NULL) {
					check_semantic_errors($2, $2->type, $2->nom);
					$2->fils = create_node_children(mk_single_node("BLOC"), $2->fils, NULL, NULL, NULL);
					$2 = $2->suivant;
				}
				generateDot(programme, "test.dot");
				free_tree(programme);
				printf("Memory successfully freed!\n");
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
			if (scope == 0) {
				$$ = inserer(global, $1->nom);
			} else {
				$$ = inserer(local, $1->nom);
			}
		}
	|	declarateur {
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
			$$->tab_dimension = tab_dimension;
			tab_dimension = 0;
		}
;
tableau_decl:
	IDENTIFICATEUR {
		if (scope == 0) {
			$$ = inserer(global, $1->nom);
		} else {
			$$ = inserer(local, $1->nom);
		}
	 }
	| tableau_decl '[' expression ']' {
			tab_dimension++;
			$$ = $1;
		}
;
fonction:
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {
			$$->fils = $8;
			$$->nom = $2->nom;
			$$->type = $1->type;
			$$->is_func = 1;
			ajouter_fonction($1->type, $2->nom, $4);
			table_reset(local);
		}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {
			ajouter_fonction($2->type, $3->nom, $5);
			$$ = mk_single_node("EXTERN");
			$$->is_func = 1;
		}
;
type	:
		VOID	{ $$ = create_node("_VOID", _VOID); }
	|	INT		{ $$ = create_node("_INT", _INT); }
;
create_liste_param :
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
			$$ = $1;
		}
	| {
		$$ = NULL;
	}
;
parm	:
		INT IDENTIFICATEUR	{
				$$ = create_param(_INT, $2->nom);
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
		iteration { $$ = $1; }
	|	selection { $$ = $1;}
	|	saut { $$ = $1; }
	|	affectation ';' { $$ = $1; }
	|	bloc { $$ = $1; }
	|	appel { $$ = $1; }
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
			node_t *node_then = create_node_children(mk_single_node("THEN"), $5, NULL, NULL, NULL);
			$$ = create_node_children(mk_single_node("IF"), $3, node_then, NULL, NULL);
		}
	|	IF '(' condition ')' instruction ELSE instruction {
			node_t *node_then = create_node_children(mk_single_node("THEN"), $5, NULL, NULL, NULL);
			node_t *node_else = create_node_children(mk_single_node("ELSE"), $7, NULL, NULL, NULL);
			node_t *if_node = create_node_children(mk_single_node("IF"), $3, node_then, node_else, NULL);
			$$ = if_node;
		}
	|	SWITCH '(' expression ')' instruction {
			// check_type($3);
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
			if (!strcmp("TAB", $1->nom)) {
				check_tab($1);
			}
			else {
				symbole_t *s = search_var(local, $1->nom);
				if (s == NULL) {
					s = search_var(global, $1->nom);
				}
				if (s != NULL && scope >= s->scope) {
					// pas d'erreurs
				} else {
					char *tmp = malloc(sizeof(char));
					sprintf(tmp, "La variable %s n'a pas encore été déclaré.\n", $1->nom);
					semantic_error(tmp);
				}
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
			insert_children($1, $3);
			$$ = $1;
			$$->is_appel = 1;
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
expression :

	'(' expression ')' { $$ = $2; }
	| expression PLUS expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression MOINS expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression DIV expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression MUL expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression RSHIFT expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression LSHIFT expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression BAND expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| expression BOR expression {
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
	| MOINS expression %prec MOINS { $$ = create_node_children($1, $2, NULL, NULL, NULL); }
	| CONSTANTE { $$ = $1;  }
	| variable {
		if (!strcmp("TAB", $1->nom)) {
			check_tab($1);
		}
		else {
			symbole_t *s = search_var(local, $1->nom);
			if (s == NULL) {
				s = search_var(global, $1->nom);
			}
			if (s != NULL && scope >= s->scope) {
				// pas d'erreurs
			} else {
				char *tmp = malloc(sizeof(char));
				sprintf(tmp, "La variable %s n'a pas encore été déclaré.", $1->nom);
				semantic_error(tmp);
			}
		}
		$$ = $1;
	}

	| IDENTIFICATEUR '(' liste_expressions ')' {
		$$->is_appel = 1;
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
	|	expression binary_comp expression {

//		check_type($1);
//		check_type($3);
		$$ = create_node_children($2, $1, $3, NULL, NULL);}
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
	fprintf(stderr, "%sSyntax error at line %d:%d : %s\n", KRED, yylineno, yycol, s);
	fprintf(stderr, "%s", KNRM);
	exit(EXIT_FAILURE);
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