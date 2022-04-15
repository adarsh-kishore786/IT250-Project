%{
  #include <stdio.h>
  #include "parser.tab.h"
  extern YYSTYPE yylval;
%}

%%
; return DELIM;
START return START;
END return END;
SAY return PRINT;

[0-9]+ { yylval.ival = atoi(yytext); return NUMBER; }
\"[a-zA-Z0-9]*\" { yylval.sval = yytext; return STRING; }
[\+\-\*/%()"] { return *yytext; }
[ \n\t]
"(.+)" return *yytext;
%%

int yywrap() {
  return 1;
}
