%{
  #include <stdio.h>
  #include "parser.tab.h"
  extern int yylval;
%}

%%
[0-9]+ { yylval = atoi(yytext); return NUMBER; }
[\+\-\*/%()] { return *yytext; }
\n return NL;
[ \t] return SPACE;
%%

int yywrap() {
  return 1;
}
