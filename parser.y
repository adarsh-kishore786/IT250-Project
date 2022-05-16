%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #define YYSTYPE char*

  typedef struct elem etype;
  typedef enum dattype dtyp;

  int yylex();
  void yyerror(const char*);
  extern FILE* yyin;
  char words[100];
  char compileSuccess = 1;


  enum dattype { NULL_TYPE, VAR_T, NUM_T, TEMP_T, OPR_T, TEXT_T };
  char disptype[] = { 0, 0, 0, 't', 0, 0 };

  struct elem {
    dtyp type;
    char *value;
  };

  dtyp lht, rht;

  etype symbols[100];
  int numSym = 0;
  
  etype stack[100];
  int top = -1;

  int temp = 0, loop = 1, decision = 1;

  char indents[100] = {0};
  int ident = 0;

  void addSym();
  int checkType();
  dtyp checkSym();
  dtyp isInSymTable();
  void push(etype);
  void cpush(dtyp);
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
  void printSymbols();
%}

%token DELIM
%token START END
%token PRINT IF ELSE THEN ELIF EIF WHILE DO EWHILE GET LET
%token TEXT T_NUM T_TEXT NL
%token NUMBER ID
%token EQUALITY SEQ
%nonassoc '<' '>' SEQ
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%%

R: START statements END { programEnded(); printSymbols(); } R { YYACCEPT; }
  |
  ;

statements: line DELIM statements
  | error DELIM statements { yyerrok; }
  |
  ;

line: expr
  | IF '(' condition ')' THEN { genIf(); } statements EIF { genEIf(); }
  | WHILE { genStartWhile(); } '(' condition ')' DO { genWhile(); } statements EWHILE { genEWhile(); }
  | ID { lht = checkSym(); if(!lht) YYERROR; else cpush(VAR_T); } SEQ assr
  | PRINT prr
  | GET ID { if(!checkSym()) YYERROR; else printf("%s input %s\n", indents, yylval); }
  | LET T_NUM ID { addSym(NUM_T); }
  | LET T_TEXT ID { addSym(TEXT_T); }
  |
  ;

prr: TEXT { printf("%s print %s\n", indents, yylval); }
  | ID { if(!checkSym()) YYERROR; else printf("%s print %s\n", indents, yylval); }
  | NUMBER { printf("%s print %s\n", indents, yylval); }
  ;

assr: expr { rht = NUM_T; if(!checkType(lht, rht)) YYERROR; else genAssign(); }
  | TEXT { rht = TEXT_T; if(!checkType(lht, rht)) YYERROR; else { cpush(TEXT_T); genAssign(); } }
  ;

condition: expr {  }
  | expr EQUALITY { etype x = { OPR_T, "EQ" }; push(x); } expr {  }
  | expr '<' { etype x = { OPR_T, "<" }; push(x); } expr {  }
  | expr '>' { etype x = { OPR_T, ">" }; push(x); } expr {  }
  | expr '<' SEQ { etype x = { OPR_T, "<=" }; push(x); } expr {  }
  | expr '>' SEQ { etype x = { OPR_T, ">=" }; push(x); } expr {  }
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
  | ID { dtyp x = checkSym(); if(!x || !checkType(x, NUM_T)) YYERROR; else cpush(VAR_T); }
  | '-' expr { etype x = {OPR_T, "-"}; push(x); genUnary(); }
  | '+' expr { etype x = {OPR_T, "+"}; push(x); genUnary(); }
  ;

%%

void addSym(dtyp T) {
  char* s = calloc(strlen(yylval) + 1, 1);
  strcpy(s, yylval);
  etype x = {T, s};
  symbols[numSym] = x;
  numSym++;
}

int checkType(dtyp a, dtyp b) {
  if(a == b) return 1;
  char s[200];
  sprintf(s, "Types %s and %s do not match", (a == NUM_T) ? "NUM" : "STRING", (b == NUM_T) ? "NUM" : "STRING");
  yyerror(s);
  return 0;
}

dtyp checkSym() {
  dtyp ans = isInSymTable(yylval);
  if(!ans) {
    // printf("symbol \" %s \" not declared\n", yylval);
    char s[200];
    sprintf(s, "symbol \" %s \" not declared\n", yylval);
    yyerror(s);
    return 0;
  }
  return ans;
}

dtyp isInSymTable(char* x) {
  for(int i = 0; i < numSym; i++) {
    if(strcmp(symbols[i].value, x) == 0)
      return symbols[i].type;
  }
  return 0;
}

void cpush(dtyp T) {
  char* s = calloc(strlen(yylval) + 1, 1);
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
  char* s = (char *) calloc(4, 1);
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
  char* s = (char *) calloc(4, 1);
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
  char* s = (char *) calloc(4, 1);
  snprintf(s, 4, "%d", temp++);
  etype z = {TEMP_T, s};
  printf("%s %c%s = %c%s %c%s %c%s\n", indents, disptype[z.type], z.value, disptype[c.type], c.value, disptype[b.type], b.value, disptype[a.type], a.value);
  push(z);
}

void genAssign() {
  etype x = pop();
  etype y = pop();
  printf("%s %c%s = %c%s\n", indents, disptype[y.type], y.value, disptype[x.type], x.value);
}

void printSymbols() {
    printf("\n\tSymbol Table\nData Type\tName\n");
    for(int i = 0; i < numSym; i++) {
        if(symbols[i].type == NUM_T)
            printf("NUM      \t%s\n", symbols[i].value);
        else
            printf("STRING   \t%s\n", symbols[i].value);
    }
    printf("\n");
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
        printf("\nProgram compiled successfully\n\n");
    else
        printf("\nProgram compilation failed with error\n\n");
    compileSuccess = 1;
}
