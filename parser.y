%{
  #include <stdio.h>
  #include <string.h>

  #define YYSTYPE char*

  typedef struct elem etype;

  int yylex();
  void yyerror(const char*);
  extern FILE* yyin;
  char words[100];
  char compileSuccess = 1;

  enum dattype { VAR_T, NUM_T, TEMP_T, OPR_T };
  char disptype[] = { 0, 0, 't', 0 };

  struct elem {
    enum dattype type;
    char *value;
  };

  etype stack[100];
  int top = -1;

  int temp = 0, loop = 1, decision = 1;

  char indents[100] = {0};
  int ident = 0;

  void push(etype);
  void cpush(enum dattype);
  etype pop();
  etype genBinary();
  etype genUnary();
  void genAssign();
  void genCond();
  void genStartWhile();
  void genWhile();
  void genEWhile();
  void genIf();
  void genEIf();
  void programEnded();
%}

%token DELIM
%token START END
%token PRINT IF ELSE THEN ELIF EIF WHILE DO EWHILE GET
%token TEXT NL
%token NUMBER ID
%token EQUALITY
%nonassoc '<' '>' '='
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%type <ival> expr term;

%%

R: START statements END { programEnded(); }
  |
  ;

statements: line DELIM statements
  | error DELIM statements { yyerrok; }
  |
  ;

line: expr
  | IF '(' condition ')' THEN { genIf(); } statements EIF { genEIf(); }
  | WHILE { genStartWhile(); } '(' condition ')' DO { genWhile(); } statements EWHILE { genEWhile(); }
  | ID { cpush(VAR_T); } '=' expr { genAssign(); }
  | PRINT TEXT { printf("%s print %s\n", indents, yylval); }
  | PRINT ID { printf("%s print %s\n", indents, yylval); }
  | GET ID { printf("%s input %s\n", indents, yylval); }
  |
  ;

condition: expr {  }
  | expr EQUALITY { etype x = { OPR_T, "==" }; push(x); } expr {  }
  | expr '<' { etype x = { OPR_T, "<" }; push(x); } expr {  }
  | expr '>' { etype x = { OPR_T, ">" }; push(x); } expr {  }
  | expr '<' '=' { etype x = { OPR_T, "<=" }; push(x); } expr {  }
  | expr '>' '=' { etype x = { OPR_T, ">=" }; push(x); } expr {  }
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
  printf("%s %c%s = %c%s %c%s\n", indents, disptype[z.type], z.value, disptype[x.type], x.value, disptype[y.type], y.value);
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
  printf("%s %c%s = %c%s %c%s %c%s\n", indents, disptype[z.type], z.value, disptype[c.type], c.value, disptype[b.type], b.value, disptype[a.type], a.value);
  push(z);
  return z;
}

void genStartWhile() {
  printf("%s L_%d:\n", indents, loop);
  indents[ident] = '\t';
  indents[ident+1] = 0;
  ident++;
}

void genWhile() {
  genCond();
  etype a = pop();
  printf("%s t%d = not %c%s\n", indents, temp, disptype[a.type], a.value);
  printf("%s IF t%d JMP TO End_L_%d\n", indents, temp, loop);
  loop++;
  temp++;
}

void genEWhile() {
  --loop;
  printf("%s JMP TO L_%d\n", indents, loop);
  indents[ident-1] = 0;
  ident--;
  printf("%s End_L_%d:\n", indents, loop);
}

void genIf() {
  genCond();
  etype a = pop();
  printf("%s t%d = not %c%s\n", indents, temp, disptype[a.type], a.value);
  printf("%s IF t%d JMP TO End_I_%d:\n", indents, temp, decision);
  indents[ident] = '\t';
  indents[ident+1] = 0;
  ident++;
  decision++;
  temp++;
}

void genEIf() {
  --decision;
  indents[ident-1] = 0;
  ident--;
  printf("%s End_I_%d:\n", indents, decision);
}

void genCond() {
  etype a = pop();
  etype b = pop();
  etype c = pop();
  char* s = (char *) malloc(4);
  snprintf(s, 4, "%d", temp++);
  etype z = {TEMP_T, s};
  printf("%s %c%s = %c%s %c%s %c%s\n", indents, disptype[z.type], z.value, disptype[c.type], c.value, disptype[b.type], b.value, disptype[a.type], a.value);
  push(z);
}

void genAssign() {
  etype x = pop();
  etype y = pop();
  printf("%s %c%s %c%s\n", indents, disptype[y.type], y.value, disptype[x.type], x.value);
}

int main(int argc, char *argv[]) {
  FILE *fp;
  fp = fopen(argv[1], "r");
  yyin = fp;
  yyparse();
  return 0;
}

void yyerror(const char* s) {
  printf("-----> %s\n", s);
  compileSuccess = 0;
}

void programEnded() {
    if(compileSuccess)
        printf("\nProgram compiled successfully\n");
    else
        printf("\nProgram compilation failed with error\n");
    compileSuccess = 1;
}
