%{
  #include <stdio.h>
  #include "parser.tab.h"
  extern int yylval;
  extern char words[100];
%}

%%
; return DELIM;
START return START;
END return END;
SAY return PRINT;
[0-9]+ { yylval = atoi(yytext); return NUMBER; }
[\+\-\*/%()"] { return *yytext; }
[ \n\t]
"(.+)" return *yytext;
%%

int yywrap() {
  return 1;
}
