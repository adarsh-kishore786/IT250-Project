%option noinput nounput noyywrap

%{
  #include <stdio.h>
  #include "parser.tab.h"

  extern YYSTYPE yylval;
%}


%%
[0-9]+ { yylval.ival = atoi(yytext); return NUMBER; }

\"[a-zA-Z0-9]*\" {
    yylval.sval = yytext;
    return STR; 
}

[\+\-\*/%()] { return *yytext; }

"say" { return PRINT; }

\n return NL;
[ \t] ;
%%
