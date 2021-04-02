D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
comment    (((\/\*+[\s\S]*?\*\/)|(\/\*+.*\*\/))|(\/{2}.*))*

%{
/*
    D                       [0-9]    chiffres
    L                       [a-zA-Z_]   alpha + underscore
    H                       [a-fA-F0-9]     hexa
    E                       [Ee][+-]?{D}+   e-1564546 (notation scientifique)
    FS                      (f|F|l|L)   float / long
    IS                      (u|U|l|L)*   unsigned / long
*/
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "symboles.h"
// symbole *table[TAILLE];
int current_idx = 0;

/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */
%}

%%
"break"                 { return debugger(yytext, BREAK, "BREAK"); return BREAK; }
"case"                  { return debugger(yytext, CASE, "CASE"); return CASE; }
"default"               { return debugger(yytext, DEFAULT, "DEFAULT"); return DEFAULT; }
"else"                  { return debugger(yytext, ELSE, "ELSE"); return ELSE; }
"extern"                { return debugger(yytext, EXTERN, "EXTERN"); return EXTERN; }
"for"                   { return debugger(yytext, FOR, "FOR"); return FOR; }
"if"                    { return debugger(yytext, IF, "IF"); return IF; }
"int"                   {
    yylval.type = _INT;
    return debugger(yytext, INT, "INT"); return INT ;}
"return"                { return debugger(yytext, RETURN, "RETURN"); return RETURN; }
"switch"                { return debugger(yytext, SWITCH, "SWITCH"); return SWITCH; }
"void"                  { return debugger(yytext, VOID, "VOID"); return VOID; }
"while"                 { return debugger(yytext, WHILE, "WHILE"); return WHILE; }

{L}({L}|{D})*           {
    int hash_yytext = hash(yytext);
    symbole* new_symb = inserer(yytext);
    table[hash_yytext] = new_symb;
    yylval.symbole_ptr = new_symb;
    // printf("table[hash(yytext)] : %s\n", table[hash_yytext]->nom);
    return debugger(yytext, IDENTIFICATEUR, "IDENTIFICATEUR"); return IDENTIFICATEUR; }

0[xX]{H}+{IS}?          {
                        yylval.val = atoi(yytext);
                        // table[hash(yylval.nom)]->valeur = yylval.value;
                        // printf("table %s = %d",yylval.nom, table[hash(yylval.nom)]->valeur);

                        return debugger(yytext, CONSTANTE, "CONSTANTE"); return CONSTANTE; }
0{D}+{IS}?              { yylval.val = atoi(yytext);
                        // table[hash(yylval.nom)]->valeur = yylval.value;
                        // printf("table %s = %d",yylval.nom, table[hash(yylval.nom)]->valeur);
return debugger(yytext, CONSTANTE, "CONSTANTE"); return CONSTANTE; }
{D}+{IS}?               { yylval.val = atoi(yytext);
                        // table[hash(yylval.nom)]->valeur = yylval.value;
                        // printf("table %s = %d",yylval.nom, table[hash(yylval.nom)]->valeur);
return debugger(yytext, CONSTANTE, "CONSTANTE"); return CONSTANTE; }
L?'(\\.|[^\\'])+'       { ; }

{D}+{E}{FS}?            { return CONSTANTE; }
{D}*"."{D}+({E})?{FS}?  { ; }
{D}+"."{D}*({E})?{FS}?  { ; }
{comment}               { printf("commentaire : %s\n", yytext); }

L?\"(\\.|[^\\"])*\"     { ; }



"&="                    { return debugger(yytext, BAND, "BAND"); return BAND; }
"|="                    { return debugger(yytext, BOR, "BOR"); return BOR; }
">>"                    { return debugger(yytext, RSHIFT, "RSHIFT"); return RSHIFT; }
"<<"                    { return debugger(yytext, LSHIFT, "LSHIFT"); return LSHIFT; }
"&&"                    { return debugger(yytext, LAND, "LAND"); return LAND; }
"||"                    { return debugger(yytext, LOR, "LOR"); return LOR; }
"<="                    { return debugger(yytext, LEQ, "LEQ"); return LEQ; }
">="                    { return debugger(yytext, GEQ, "GEQ"); return GEQ; }
"=="                    { return debugger(yytext, EQ, "EQ"); return EQ; }
"!="                    { return debugger(yytext, NEQ, "NEQ"); return NEQ; }
"!"                     { return debugger(yytext, NOT, "NOT"); return NOT; }

"-"                     { return debugger(yytext, MOINS, "MOINS"); return MOINS; }
"/"                     { return debugger(yytext, DIV, "DIV"); return DIV; }
"*"                     { return debugger(yytext, MUL, "MUL"); return MUL; }
"<"                     { return debugger(yytext, LT, "LT"); return LT; }
">"                     { return debugger(yytext, GT, "GT"); return GT; }
"+"                     { return debugger(yytext, PLUS, "PLUS"); return PLUS; }

[\n]                    { yylineno++; }
[ \t\v\f]               { ; }
[();,{}:\[\]=]          { return *yytext; }
.                       { printf("Lexical error at line %d : %s\n", yylineno,  yytext[0]);
                            exit(EXIT_FAILURE); }
%%

/* Analyseur lexicale */
main () {
    while (yyparse());
}