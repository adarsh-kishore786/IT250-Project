%{
  #include <stdio.h>
  int yylex();
  void yyerror(const char*);
  extern FILE* yyin;
%}

%union {
    double dval;
    int ival;
    char *sval;
}

%token NUMBER NL SPACE
%token PRINT STR

%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%type <ival> expr term;

%%
program: R NL program | stmt NL program | ;

stmt: PRINT STR
    {
        printf("printf(%s);\n", $<sval>2);
    }
    |
    ;

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

term: NUMBER { $$ = $<ival>1; }
  | '-' expr { $$ = -$2; }
  | '+' expr { $$ = $2; }

space: SPACE { printf("here is some space\n"); }
%%

int main(int argc, char *argv[]) {
  FILE *fp;
  fp = fopen(argv[1], "r");
  yyin = fp;
  yyparse();
  return 0;
}

void yyerror(const char* s) {
  printf("%s\n", s);
}
