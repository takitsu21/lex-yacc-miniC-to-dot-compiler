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
yycol = 0;
fun_cursor = 0;

/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */
%}
%option yylineno

%%
{comment}               { printf("commentaire : %s\n", yytext); }
"break"                 { return debugger(yytext, BREAK, "BREAK"); return BREAK; }
"case"                  { return debugger(yytext, CASE, "CASE"); return CASE; }
"default"               { return debugger(yytext, DEFAULT, "DEFAULT"); return DEFAULT; }
"else"                  { return debugger(yytext, ELSE, "ELSE"); return ELSE; }
"extern"                { return debugger(yytext, EXTERN, "EXTERN"); return EXTERN; }
"for"                   { return debugger(yytext, FOR, "FOR"); return FOR; }
"if"                    { return debugger(yytext, IF, "IF"); return IF; }
"int"                   {
    return debugger(yytext, INT, "INT"); return INT ;}
"return"                { return debugger(yytext, RETURN, "RETURN"); return RETURN; }
"switch"                { return debugger(yytext, SWITCH, "SWITCH"); return SWITCH; }
"void"                  {
    return debugger(yytext, VOID, "VOID"); return VOID; }
"while"                 {
    return debugger(yytext, WHILE, "WHILE"); return WHILE; }

{L}({L}|{D})*           {
    node_t *node = create_node(strdup(yytext), NULL);
    yylval.node = node;
    return debugger(yytext, IDENTIFICATEUR, "IDENTIFICATEUR"); return IDENTIFICATEUR;
    }

0[xX]{H}+{IS}?          {
            node_t *node = create_node(strdup(yytext), NULL);
            yylval.node = node;
            return debugger(yytext, CONSTANTE, "CONSTANTE"); return CONSTANTE;
        }
0{D}+{IS}?              {
    node_t *node = create_node(strdup(yytext), NULL);
    yylval.node = node;
    return debugger(strdup(yytext), CONSTANTE, "CONSTANTE"); return CONSTANTE; }
{D}+{IS}?               {
    node_t *node = create_node(strdup(yytext), NULL);
    yylval.node = node;
    return debugger(yytext, CONSTANTE, "CONSTANTE"); return CONSTANTE; }
L?'(\\.|[^\\'])+'       { ; }

{D}+{E}{FS}?            {
    node_t *node = create_node(strdup(yytext), NULL);
    yylval.node = node;
    return CONSTANTE; }
{D}*"."{D}+({E})?{FS}?  {
    node_t *node = create_node(strdup(yytext), NULL);
    yylval.node = node;
    return CONSTANTE; }
{D}+"."{D}*({E})?{FS}?  {
    node_t *node = create_node(strdup(yytext), NULL);
    yylval.node = node;
    return CONSTANTE;
 }


L?\"(\\.|[^\\"])*\"     { ; }



"&"                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, BAND, "BAND"); return BAND; }
"|"                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, BOR, "BOR"); return BOR; }
">>"                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, RSHIFT, "RSHIFT"); return RSHIFT; }
"<<"                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, LSHIFT, "LSHIFT"); return LSHIFT; }
"&&"                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, LAND, "LAND"); return LAND; }
"||"                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, LOR, "LOR"); return LOR; }
"<="                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, LEQ, "LEQ"); return LEQ; }
">="                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, GEQ, "GEQ"); return GEQ; }
"=="                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, EQ, "EQ"); return EQ; }
"!="                    {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, NEQ, "NEQ"); return NEQ; }
"!"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, NOT, "NOT"); return NOT; }

"-"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, MOINS, "MOINS"); return MOINS; }
"/"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, DIV, "DIV"); return DIV; }
"*"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, MUL, "MUL"); return MUL; }
"<"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, LT, "LT"); return LT; }
">"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, GT, "GT"); return GT; }
"+"                     {
    yylval.node = create_node(yytext, NULL); return debugger(yytext, PLUS, "PLUS"); return PLUS; }

\n                      { yycol = 0; }
[ \t\v\f\n]               { ; }
[();,{}:\[\]=]          { return *yytext; }
.                       { printf("Lexical error at line %d:%d : %s\n", yylineno, yycol,  *yytext);
                            exit(EXIT_FAILURE); }
%%

main () {
    while (yyparse());
}

