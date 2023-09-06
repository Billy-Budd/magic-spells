%{
/* FlexicalAnalysis.l
 * JML190001 - John Lawler
 * CS4386.501 Project Two A
 * 03/22/23
 * Program provides lexical tokens for the parser, YaketyYak.y.
 * Program will continue on a lexical error, but it will stop if it meets a parsing error. 
 * Major change: main was moved from this file to parser file. 
 * Minor change: NUM now accepts 0 in order to account for the 0 in the while loop
 * Minor change: %option noyywrap
 * Major change: this is now wholly in C rather than C/C++ on account of trying to fix errors
 * Minor change: no longer supports windows executable as it is now in C (and coded on a linux server), possible creation in the future
 */
#include "HandItOver.h"
#include "YaketyYak.tab.h"
extern int yylineno;
int errCount = 0;
%}

%option yylineno
%option noyywrap

%%
[ \t\r\n]|%.*               ;
[0-9]+                      { yylval.sval = strdup(yytext); return NUM; }
false|true                  { yylval.sval = strdup(yytext); return BOOLVAR; }
[A-Z][A-Z0-9]*              { yylval.sval = strdup(yytext); return ident; }
"("                         { yylval.sval = strdup(yytext); return LP; }
")"                         { yylval.sval = strdup(yytext); return RP; }
":="                        { yylval.sval = strdup(yytext); return ASGN; }
";"                         { yylval.sval = strdup(yytext); return SC; }
"*"|"div"|"mod"             { yylval.sval = strdup(yytext); return OP2; }
"+"|"-"                     { yylval.sval = strdup(yytext); return OP3; }
"="|"!="|"<"|">"|"<="|">="  { yylval.sval = strdup(yytext); return OP4; }
"if"                        { yylval.sval = strdup(yytext); return IF; }
"then"                      { yylval.sval = strdup(yytext); return THEN; }
"else"                      { yylval.sval = strdup(yytext); return ELSE; }
"begin"                     { yylval.sval = strdup(yytext); return BEGN; }
"end"                       { yylval.sval = strdup(yytext); return END; }
"while"                     { yylval.sval = strdup(yytext); return WHILE; }
"do"                        { yylval.sval = strdup(yytext); return DO; }
"program"                   { yylval.sval = strdup(yytext); return PROGRAM; }
"var"                       { yylval.sval = strdup(yytext); return VAR; }
"as"                        { yylval.sval = strdup(yytext); return AS; }
"int"                       { yylval.sval = strdup(yytext); return INT; }
"bool"                      { yylval.sval = strdup(yytext); return BOOL; }
"writeInt"                  { yylval.sval = strdup(yytext); return WRITEINT; }
"readInt"                   { yylval.sval = strdup(yytext); return READINT; }
.                           { printf("Error: Unrecognized Token: %s on line %d\n", yytext, yylineno); errCount++;}                 
%%