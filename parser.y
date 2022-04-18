%{
  #include <stdio.h>
  int yylex();
  void yyerror(const char*);
  FILE* yyin;
  char words[100];
  int condition;
%}

%token DELIM
%token START END
%token PRINT IF ELSE THEN ELIF EIF WHILE DO EWHILE
%token TEXT NL
%token NUMBER
%token EQUALITY
%nonassoc '<' '>'
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%%

R: START statements END { printf("Program compiled successfully\n"); }
  |
  ;

statements: line DELIM statements
  |
  ;

line: expr
  | IF '(' condition ')' THEN statements EIF { condition = $3; }
  | WHILE '(' condition ')' DO statements EWHILE { condition = $3; }
  | ;

condition: expr EQUALITY expr { $$ = $1 == $3; }
  | expr '<' expr { $$ = $1 < $3; }
  | expr '>' expr { $$ = $1 > $3; }
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
