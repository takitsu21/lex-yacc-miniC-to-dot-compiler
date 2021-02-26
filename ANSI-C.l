D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "y.tab.h"
int yylval;


/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
"auto"                  { /* A completer */ }
"break"                 { return BREAK; }
"case"                  { return CASE; }
"char"                  { /* A completer */ }
"const"                 { return CONSTANTE; }
"continue"              { /* A completer */ }
"default"               { return DEFAULT; }
"do"                    { /* A completer */ }
"double"                { /* A completer */ }
"else"                  { return ELSE; }
"enum"                  { /* A completer */ }
"extern"                { return EXTERN; }
"float"                 { /* A completer */ }
"for"                   { return FOR; }
"goto"                  { /* A completer */ }
"if"                    { return IF; }
"int"                   { return INT; }
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

{L}({L}|{D})*           { return IDENTIFICATEUR; } // ID peut etre ???

0[xX]{H}+{IS}?          { /* A completer */ } // hexa ???
0{D}+{IS}?              { /* A completer */ }
{D}+{IS}?               { /* A completer */ }
L?'(\\.|[^\\'])+'       { /* A completer */ }

{D}+{E}{FS}?            { /* A completer */ }
{D}*"."{D}+({E})?{FS}?  { /* A completer */ }
{D}+"."{D}*({E})?{FS}?  { /* A completer */ }

L?\"(\\.|[^\\"])*\"     { /* A completer */ }

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

[ \t\v\n\f]             { /* A completer */ }
.                       { return yytext[0]; }
%%

