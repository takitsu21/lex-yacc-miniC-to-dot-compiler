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
// #include "librairie.h"
#include "y.tab.h"
int yylval;
// char* dotString;


/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"else"                  { return ELSE; }
"extern"                { printf("%s ", yytext); return EXTERN; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { printf("%s ", yytext);
                            return INT; }
"return"                { printf("%s ", yytext); return RETURN; }
"switch"                { return SWITCH; }
"void"                  { return VOID; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { printf("[IDENTIFICATEUR : %s ]", yytext); return IDENTIFICATEUR; }

0[xX]{H}+{IS}?          { ; }
0{D}+{IS}?              { return CONSTANTE; }
{D}+{IS}?               { printf("%s ", yytext); return CONSTANTE; }
L?'(\\.|[^\\'])+'       { ; }

{D}+{E}{FS}?            { return CONSTANTE; }
{D}*"."{D}+({E})?{FS}?  { ; }
{D}+"."{D}*({E})?{FS}?  { ; }
{comment} {printf("commentaire : %s\n", yytext);}

L?\"(\\.|[^\\"])*\"     {; }



"&="                    { return BAND; }
"|="                    { return BOR; }
">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT; }
"&&"                    { return LAND; }
"||"                    { return LOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"!"                     {return NOT; }

"+"                     { printf("%s ", yytext); return PLUS; }
"-"                     { printf("%s ", yytext); return MOINS; }
"/"                     { printf("%s ", yytext); return DIV; }
"*"                     { printf("%s ", yytext); return MUL; }
"="                     { printf("%s ", yytext); return IDENTIFICATEUR; }
"<"                     { printf("%s ", yytext); return LT; }
">"                     { printf("%s ", yytext); return GT; }


[\n]                    { yylineno = yylineno + 1; printf("\n[%d] ", yylineno); }
[ \t\v\f\n]             { ; };
[();,{}:\[\]]           { printf("%s", yytext); return yytext[0]; }
.                       { printf("Lexical error at line %d : %s\n", yylineno, yytext);
                            exit(1); }
%%

/* Analyseur lexicale */
// main () {
//     while (yylex());
// }