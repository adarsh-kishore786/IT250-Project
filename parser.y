%{
  #include <stdio.h>
  int yylex();
  void yyerror(const char*);
%}

%token NUMBER NL SPACE
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%%
program: program R NL | ;

R: expr { printf("%d\n", $1); }
  | space
  ;

expr: expr '+' expr { $$ = $1 + $3; }
  | expr '-' expr { $$ = $1 - $3; }
  | expr '*' expr { $$ = $1 * $3; }
  | expr '/' expr { $$ = $1 / $3; }
  | expr '%' expr { $$ = $1 % $3; }
  | '(' expr ')' { $$ = $2; }
  | term
  ;

term: NUMBER
  | '-' expr { $$ = -$2; }
  | '+' expr { $$ = $2; }

space: SPACE { printf("here is some space\n"); }
%%

int main() {
  yyparse();
  return 0;
}

void yyerror(const char* s) {
  printf("%s\n", s);
}
