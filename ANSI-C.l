D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
comment                 (\/\*)(.|\r|\n)*?(\*\/)|"//".*

%{
/*
    D                       [0-9]    chiffres
    L                       [a-zA-Z_]   alpha + underscore
    H                       [a-fA-F0-9]     hexa
    E                       [Ee][+-]?{D}+   e-1564546 (notation scientifique)
    FS                      (f|F|l|L)   float / long
    IS                      (u|U|l|L)*   unsigned / long
*/
#include "y.tab.h"
#include "symboles.h"
yycol = 0;
scope = 0;
/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */
%}
%option yylineno

%%
{comment}               { ; }
"break"                 { return debugger(yytext, BREAK, "BREAK"); }
"case"                  { return debugger(yytext, CASE, "CASE"); }
"default"               { return debugger(yytext, DEFAULT, "DEFAULT"); }
"else"                  { return debugger(yytext, ELSE, "ELSE"); }
"extern"                { return debugger(yytext, EXTERN, "EXTERN"); }
"for"                   { return debugger(yytext, FOR, "FOR"); }
"if"                    { return debugger(yytext, IF, "IF"); }
"int"                   { return debugger(yytext, INT, "INT"); }
"return"                { return debugger(yytext, RETURN, "RETURN"); }
"switch"                { return debugger(yytext, SWITCH, "SWITCH"); }
"void"                  { return debugger(yytext, VOID, "VOID"); }
"while"                 { return debugger(yytext, WHILE, "WHILE"); }

{L}({L}|{D})*           {
        node_t *node = create_node(strdup(yytext), NULL);
        yylval.node = node;
        return debugger(yytext, IDENTIFICATEUR, "IDENTIFICATEUR");
    }

0[xX]{H}+{IS}?          {
            node_t *node = create_node(strdup(yytext), NULL);
            yylval.node = node;
            return debugger(yytext, CONSTANTE, "CONSTANTE");
        }

0{D}+{IS}?              {
        node_t *node = create_node(strdup(yytext), NULL);
        yylval.node = node;
        return debugger(strdup(yytext), CONSTANTE, "CONSTANTE");
    }
{D}+{IS}?               {
        node_t *node = create_node(strdup(yytext), NULL);
        yylval.node = node;
        return debugger(yytext, CONSTANTE, "CONSTANTE");
    }


{D}+{E}{FS}?            {
        node_t *node = create_node(strdup(yytext), NULL);
        yylval.node = node;
        return debugger(yytext, CONSTANTE, "CONSTANTE");
    }


"&"                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, BAND, "BAND");
    }
"|"                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, BOR, "BOR");
    }
">>"                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, RSHIFT, "RSHIFT");
    }
"<<"                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, LSHIFT, "LSHIFT");
    }
"&&"                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, LAND, "LAND");
    }
"||"                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, LOR, "LOR");
    }
"<="                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, LEQ, "LEQ");
    }
">="                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, GEQ, "GEQ");
    }
"=="                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, EQ, "EQ");
    }
"!="                    {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, NEQ, "NEQ");
    }
"!"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, NOT, "NOT");
    }

"-"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, MOINS, "MOINS");
    }
"/"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, DIV, "DIV");
    }
"*"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, MUL, "MUL");
    }
"<"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, LT, "LT");
    }
">"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, GT, "GT");
    }
"+"                     {
        yylval.node = create_node(yytext, NULL);
        return debugger(yytext, PLUS, "PLUS");
    }

\n                      { yycol = 0; }
[ \t\v\f\n]               { ; }
[();,:\[\]=]          { return *yytext; }
"{"                     { scope++; return *yytext; }
"}"                     { scope--; return *yytext; }
.                       {
        fprintf(stderr, "%sLexical error at line %d:%d : %s\n", KRED, yylineno, yycol, yytext);
        fprintf(stderr, "%s", KNRM);
        exit(EXIT_FAILURE);
    }
%%


main (int argc, char *argv[]) {
    while (yyparse());
    return (EXIT_SUCCESS);
}

