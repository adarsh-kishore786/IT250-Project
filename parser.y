%{
  #include <stdio.h>
  #include <string.h>

  #define YYSTYPE char*

  typedef struct elem etype;

  int yylex();
  void yyerror(const char*);
  extern FILE* yyin;
  char words[100];
  int condition;

  enum dattype { VAR_T, NUM_T, TEMP_T, OPR_T };
  char disptype[] = { ' ', ' ', 't', ' '};

  struct elem {
    enum dattype type;
    char *value;
  };
  
  etype stack[100];
  int top = -1;

  int loopStack[100];
  int ltop = -1;

  int temp = 0, loop = 1;

  void push(etype);
  void cpush(enum dattype);
  etype pop();
  etype genBinary();
  etype genUnary();
  void genWhile();
  void genEWhile();

%}

%token DELIM
%token START END
%token PRINT IF ELSE THEN ELIF EIF WHILE DO EWHILE
%token TEXT NL
%token NUMBER ID
%token EQUALITY
%nonassoc '<' '>'
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%%

R: START statements END { printf("\nProgram compiled successfully\n"); }
  |
  ;

statements: line DELIM statements
  |
  ;

line: expr
  | IF '(' condition ')' THEN statements EIF {  }
  | WHILE '(' condition ')' DO { genWhile(); } statements EWHILE { genEWhile(); }
  | ID '=' expr {}
  ;

condition: expr { }
  | expr EQUALITY expr {  }
  | expr '<' expr {  }
  | expr '>' expr {  }
  ;

expr:
    expr '+' { etype x = {OPR_T, "+"}; push(x); } expr { genBinary(); }
  | expr '-' { etype x = {OPR_T, "-"}; push(x); } expr { genBinary(); }
  | expr '*' { etype x = {OPR_T, "*"}; push(x); } expr { genBinary(); }
  | expr '/' { etype x = {OPR_T, "/"}; push(x); } expr { genBinary(); }
  | expr '%' { etype x = {OPR_T, "%"}; push(x); } expr { genBinary(); }
  | '(' expr ')' {  }
  | term
  ;

term: NUMBER { cpush(NUM_T); }
  | ID { cpush(VAR_T); }
  | '-' expr { etype x = {OPR_T, "-"}; push(x); genUnary(); }
  | '+' expr { etype x = {OPR_T, "+"}; push(x); genUnary(); }
  ;

%%

void cpush(enum dattype T) {
  char* s = malloc(strlen(yylval) + 1);
  strcpy(s, yylval);
  etype x = {T, s};
  push(x);
}

void push(struct elem e) {
  stack[++top] = e;
}

etype pop() {
  return stack[top--];
}

etype genUnary() {
  etype x = pop();
  etype y = pop();
  char* s = (char *) malloc(4);
  snprintf(s, 4, "%d", temp++);
  etype z = {TEMP_T, s};
  printf("%c%s = %c%s%c%s\n", disptype[z.type], z.value, disptype[x.type], x.value, disptype[y.type], y.value);
  push(z);
  return z;
}

etype genBinary() {
  etype a = pop();
  etype b = pop();
  etype c = pop();
  char* s = (char *) malloc(4);
  snprintf(s, 4, "%d", temp++);
  etype z = {TEMP_T, s};
  printf("%c%s = %c%s%c%s%c%s\n", disptype[z.type], z.value, disptype[c.type], c.value, disptype[b.type], b.value, disptype[a.type], a.value);
  push(z);
  return z;
}

void genWhile() {
  printf("L_%d:\n", loop);
  etype a = pop();
  printf("t%d = not %c%s\n", temp, disptype[a.type], a.value);
  printf("if t%d jmp to End_L%d\n", temp, loop);
  loop++;
}

void genEWhile() {
  --loop;
  printf("jmp to L_%d\n", loop);
  printf("End_L%d:\n", loop);
}

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
