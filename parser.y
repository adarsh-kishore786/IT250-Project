%{
  #include <stdio.h>
  #include <string.h>
  int yylex();
  void yyerror(const char*);
  extern FILE* yyin;
  char vname[128];
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

%type <ival> expr term
%type <sval> var

%%

R: START statements END { printf("\nProgram compiled successfully\n"); }
  |
  ;

statements: line DELIM statements
  |
  ;

line:
  expr { printf("%d\n", $1); }
  |
  PRINT STRING {
    printf("printf(%s);\n", $<sval>2);
  }
  |
  var '=' expr {
    printf("%s = %d\n", $1, $3);
  }
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
  ;

var: VARIABLE { strcpy(vname, $<sval>1); $$ = vname; }

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
