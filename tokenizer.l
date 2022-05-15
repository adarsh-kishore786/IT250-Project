%option noinput nounput noyywrap

%{
  #include <stdio.h>

  #define YYSTYPE char*
  extern YYSTYPE yylval;

  #include "parser.tab.h"

  extern char words[100];
%}


%%
; return DELIM;
START return START;
END return END;
SAY return PRINT;
[0-9]+ { yylval = yytext; return NUMBER; }
[\+\-\*/%()<>"] { yylval = yytext; return *yytext; }
[ \n\t]
"(.+)" return *yytext;
IF return IF;
EIF return EIF;
THEN return THEN;
ELIF return ELIF;
ELSE return ELSE;
WHILE return WHILE;
EWHILE return EWHILE;
DO return DO;
GET return GET;
"==" return EQUALITY;
LET return LET;
NUM return T_NUM;
STR return T_TEXT;
[a-zA-Z][a-zA-Z0-9]* { yylval = yytext; return ID; }
\"[ \n\ta-zA-Z0-9!@#$%^&*()_+=-~`<>?:"{}]*\" { yylval = yytext; return TEXT; }
. return *yytext;
%%