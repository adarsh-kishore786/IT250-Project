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
[\+\-\*/%()<>"] { return *yytext; }
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
"==" return EQUALITY;
%%

int yywrap() {
  return 1;
}
