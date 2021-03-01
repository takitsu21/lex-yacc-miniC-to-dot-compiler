D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

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
"auto"                  { /* A completer */ }
"break"                 { return BREAK; }
"case"                  { return CASE; }
"char"                  { /* A completer */ }
"const"                 { printf("const : %s", yytext); }
"continue"              { /* A completer */ }
"default"               { return DEFAULT; }
"do"                    { /* A completer */ }
"double"                { /* A completer */ }
"else"                  { return ELSE; }
"enum"                  { /* A completer */ }
"extern"                { printf("%s ", yytext); return EXTERN; }
"float"                 { /* A completer */ }
"for"                   { return FOR; }
"goto"                  { /* A completer */ }
"if"                    { return IF; }
"int"                   { printf("%s ", yytext);
                            return INT; }
"long"                  { /* A completer */ }
"register"              { /* A completer */ }
"return"                { return RETURN; }
"short"                 { /* A completer */ }
"signed"                { /* A completer */ }
"sizeof"                { /* A completer */ }
"static"                { /* A completer */ }
"struct"                { /* A completer */ }
"switch"                { return SWITCH; }
"typedef"               { /* A completer */ }
"union"                 { /* A completer */ }
"unsigned"              { /* A completer */ }
"void"                  { return VOID; }
"volatile"              { /* A completer */ }
"while"                 { return WHILE; }

{L}({L}|{D})*           { return IDENTIFICATEUR; }

0[xX]{H}+{IS}?          { printf("0[xX]{H}+{IS}? : %s\n", yytext); }
0{D}+{IS}?              { printf("0{D}+{IS}?   %s\n", yytext); return CONSTANTE; }
{D}+{IS}?               { printf("{D}+{IS}?  : %s\n", yytext); return CONSTANTE; }
L?'(\\.|[^\\'])+'       { printf("L?'(\\.|[^\\'])+'      : %s\n", yytext); }

{D}+{E}{FS}?            { printf("{D}+{E}{FS}?   : %s\n", yytext); return CONSTANTE; }
{D}*"."{D}+({E})?{FS}?  { printf("2 : %s\n", yytext); }
{D}+"."{D}*({E})?{FS}?  { printf("3 : %s\n", yytext); }

L?\"(\\.|[^\\"])*\"     { printf("L?\"(\\.|[^\\\"])*\" : %s\n", yytext); }

"..."                   { /* A completer */ }
">>="                   { /* A completer */ }
"<<="                   { /* A completer */ }
"+="                    { /* A completer */ }
"-="                    { /* A completer */ }
"*="                    { /* A completer */ }
"/="                    { /* A completer */ }
"%="                    { /* A completer */ }
"&="                    { return BAND; }
"^="                    { /* A completer */ }
"|="                    { return BOR; }
">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT; }
"++"                    { /* A completer */ }
"--"                    { /* A completer */ }
"->"                    { /* A completer */ }
"&&"                    { return LAND; }
"||"                    { return LOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }

"+"                     { return PLUS; }
"-"                     { printf("%s ", yytext); return MOINS; }
"/"                     { return DIV; }
"*"                     { return MUL; }

[ \n]   { yylineno = yylineno + 1;}
[ \t\v\f]             ;
.                       { printf("%c\n", yytext[0]); return yytext[0]; }
%%
