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
[a-zA-Z][a-zA-Z0-9]* { yylval.sval = yytext; return VARIABLE; }
[\+\-\*/%()"] { return *yytext; }
[ \n\t]
"(.+)" return *yytext;
. return yytext[0];
%%

int yywrap() {
  return 1;
}
