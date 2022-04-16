%{
  #include <stdio.h>
  #include <string.h>
  int yylex();
  void yyerror(const char*);
  extern FILE* yyin;
  char vname[128];

  int eqnCount = 0;

  struct oprCode
  {
    int t1, t2;
    int v1, v2;
    int op;
  };
%}

%union {
    int ival;
    double dval;
    char* sval;
}

%token DELIM
%token START END
%token PRINT VARIABLE
%token TEXT NL
%token NUMBER STRING FLOAT
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%left '"'
%left '='

%type <ival> term eqn

%%

R: START statements END { printf("\nProgram compiled successfully\n"); }
  |
  ;

statements: line DELIM statements
  |
  ;

line:
  eqn { printf("%d\n", $1); }
  |
  PRINT STRING {
    printf("printf(%s);\n", $<sval>2);
  }
  |
  VARIABLE '=' eqn {
    printf("%s = t%d\n", $<sval>1, $3);
  }
  ;

eqn: eqn '+' eqn { $$ = eqnCount++; printf("t%d = t%d + t%d\n", $$, $1, $3); }
  | eqn '-' eqn { $$ = eqnCount++; printf("t%d = t%d - t%d\n", $$, $1, $3); }
  | eqn '*' eqn { $$ = eqnCount++; printf("t%d = t%d * t%d\n", $$, $1, $3); }
  | eqn '/' eqn { $$ = eqnCount++; printf("t%d = t%d / t%d\n", $$, $1, $3); }
  | eqn '%' eqn { $$ = eqnCount++; printf("t%d = t%d % t%d\n", $$, $1, $3); }
  | '(' eqn ')' { $$ = $2; }
  | VARIABLE { $$ = eqnCount++; printf("t%d = %s\n", $$, $<sval>1); }
  | term { $$ = eqnCount++; printf("t%d = %d\n", $$, $1); }
  | '-' eqn { $$ = eqnCount++; printf("t%d = - t%d\n", $$, $2); }
  | '+' eqn { $$ = $2; }
  ;

term: NUMBER { $$ = $<ival>1; }
  ;

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
