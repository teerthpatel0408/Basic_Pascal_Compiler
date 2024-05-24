%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<math.h>
    #include<string.h>
    #include<ctype.h>
    #include<limits.h>
    #include "graph.c"
    extern FILE *yyin;
    
    int yylex();
    int ex (nodeType *p, int flag);
    /* function prototype to create a node for an operation */ 
    nodeType *opr(int oper, int nops, ...);
    /* function prototype to create a node for an identifier */
    nodeType *id(char *identifier);
    /* function prototype to create a node for a constat */
    nodeType *con(char *value);
%}

%union{
    int ival;
    nodeType *nPtr;
    char string[100];
}

%left PLUS MINUS OR
%left MUL DIV MOD AND
%token <string> IDENTIFIER BOOLEAN_CONST INT_CONST REAL_CONST CHAR_CONST STRING ARR TO DOWNTO
%token PROGRAM INT REAL BOOLEAN CHAR VAR TYPE IF THEN ELSE FOR DO WHILE ARRAY OF START END READ WRITE
%token PLUS MINUS MUL DIV MOD GTR LESS GTR_EQ LESS_EQ EQ NOT_EQ AND OR NOT ASS
%token SEMICOLON COMMA COLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SQT DQT DOT 
%token NEWLINE UNK END_OF_FILE PROG NUL
%type TYPE_SPECIFIER
%type <nPtr> S BLOCK VAR_DECL VAR_DECL_LIST VAR_DECL_ITEM IDENTIFIER_LIST READ_LIST STMT_LIST SMP_STMT_LIST STMT SMP_STMT ASSIGNMENT_STMT READ_STMT WRITE_STMT VAR_LIST IF_STMT WHILE_STMT FOR_STMT EXPR ARITHMETIC TERM FACTOR ARR_ACCESS CONST
%%

S : PROGRAM IDENTIFIER SEMICOLON BLOCK DOT {ex($4, 0);}
  ;

BLOCK : VAR_DECL START STMT_LIST END {$$ = opr(PROG, 2, $1, $3);}
      ;

VAR_DECL : VAR VAR_DECL_LIST {$$ = $2;}
         
         ;

VAR_DECL_LIST : VAR_DECL_LIST VAR_DECL_ITEM SEMICOLON {$$ = opr(SEMICOLON, 2, $2, $1);}
              | VAR_DECL_ITEM SEMICOLON {$$ = opr(SEMICOLON, 2, $1, opr(NUL,0));}
              ;

VAR_DECL_ITEM : IDENTIFIER_LIST COLON TYPE_SPECIFIER {$$ = $1;}
	      | IDENTIFIER_LIST COLON ARRAY LBRACKET INT_CONST DOT DOT INT_CONST RBRACKET OF TYPE_SPECIFIER {$$ = $1;}
	      ;


	      
IDENTIFIER_LIST : IDENTIFIER {$$ = id($1);}
                | IDENTIFIER_LIST COMMA IDENTIFIER {$$ = opr(COMMA, 2, id($3), $1);}
                ; 

TYPE_SPECIFIER : INT 
               | REAL 
               | BOOLEAN 
               | CHAR 
               ;

STMT_LIST : STMT SEMICOLON STMT_LIST {$$ = opr(SEMICOLON, 2, $1, $3);}
	  | STMT SEMICOLON {$$ = opr(SEMICOLON, 2, $1, opr(NUL,0));}
	  ;
          
SMP_STMT_LIST : SMP_STMT SEMICOLON SMP_STMT_LIST {$$ = opr(SEMICOLON, 2, $1, $3);}
	      | SMP_STMT SEMICOLON {$$ = opr(SEMICOLON, 2, $1, opr(NUL,0));}
	      ;

STMT : WHILE_STMT {$$ = $1;}
     | FOR_STMT {$$ = $1;}
     | SMP_STMT {$$ = $1;}
     ;

SMP_STMT : ASSIGNMENT_STMT {$$ = $1;}
     	 | READ_STMT {$$ = $1;}
     	 | WRITE_STMT {$$ = $1;}
     	 | IF_STMT {$$ = $1;}
     	 ;
   
ASSIGNMENT_STMT : IDENTIFIER ASS EXPR {$$ = opr(ASS, 2, id($1), $3);}
		| IDENTIFIER LBRACKET EXPR RBRACKET ASS EXPR {$$ = opr(ASS, 2, opr(ARR, 2, id($1), $3), $6);}
		; 

READ_STMT : READ LPAREN READ_LIST RPAREN {$$ = opr(READ, 2, $3, opr(NUL,0));}
          ;
          
READ_LIST : IDENTIFIER {$$ = id($1);}
	  | IDENTIFIER LBRACKET EXPR RBRACKET {$$ = opr(ARR, 2, id($1), $3);}
	  | READ_LIST COMMA IDENTIFIER {$$ = opr(COMMA, 2, $1, id($3));}
	  | READ_LIST COMMA IDENTIFIER LBRACKET EXPR RBRACKET {$$ = opr(COMMA, 2, $1, opr(ARR, 2, id($3), $5));}
	  ;

WRITE_STMT : WRITE LPAREN DQT STRING DQT RPAREN {$$ = opr(WRITE, 2, con($4), opr(NUL,0));}
	   | WRITE LPAREN DQT STRING DQT COMMA VAR_LIST RPAREN {$$ = opr(WRITE, 2, con($4), $7);}
           | WRITE LPAREN VAR_LIST RPAREN {$$ = opr(WRITE, 2, $3, opr(NUL,0));} 
           ;

VAR_LIST : VAR_LIST COMMA EXPR {$$ = opr(COMMA, 2, $1, $3);}
	 | EXPR {$$ = $1;}
	 ;

IF_STMT :  IF EXPR THEN START SMP_STMT_LIST END ELSE START SMP_STMT_LIST END {$$ = opr(IF, 3, $2, $5, opr(ELSE, 1, $9));}
        |  IF EXPR THEN START SMP_STMT_LIST END {$$ = opr(IF, 3, $2, $5, opr(NUL, 0));}
        ;


WHILE_STMT : WHILE EXPR DO START SMP_STMT_LIST END {$$ = opr(WHILE, 2, $2, $5);}
           ;

FOR_STMT : FOR IDENTIFIER ASS EXPR TO EXPR DO START SMP_STMT_LIST END {$$ = opr(FOR, 5, id($2), $4, con($5), $6, $9);}
	 | FOR IDENTIFIER ASS EXPR DOWNTO EXPR DO START SMP_STMT_LIST END {$$ = opr(FOR, 5, id($2), $4, con($5), $6, $9);}
	 ;

EXPR : EXPR GTR ARITHMETIC {$$ = opr(GTR, 2, $1, $3);}
     | EXPR LESS ARITHMETIC {$$ = opr(LESS, 2, $1, $3);}
     | EXPR GTR_EQ ARITHMETIC {$$ = opr(GTR_EQ, 2, $1, $3);}
     | EXPR LESS_EQ ARITHMETIC {$$ = opr(LESS_EQ, 2, $1, $3);}
     | EXPR NOT_EQ ARITHMETIC {$$ = opr(NOT_EQ, 2, $1, $3);}
     | EXPR EQ ARITHMETIC {$$ = opr(EQ, 2, $1, $3);}
     | ARITHMETIC {$$ = $1;}
     ;
     
ARITHMETIC : ARITHMETIC PLUS TERM {$$ = opr(PLUS, 2, $1, $3);}
	   | ARITHMETIC MINUS TERM {$$ = opr(MINUS, 2, $1, $3);}
           | ARITHMETIC OR TERM {$$ = opr(OR, 2, $1, $3);}
	   | TERM {$$ = $1;}
	   ;

TERM : TERM MUL FACTOR {$$ = opr(MUL, 2, $1, $3);}
     | TERM DIV FACTOR {$$ = opr(DIV, 2, $1, $3);}
     | TERM MOD FACTOR {$$ = opr(MOD, 2, $1, $3);}
     | TERM AND FACTOR {$$ = opr(AND, 2, $1, $3);}
     | FACTOR {$$ = $1;}
     ;

FACTOR : LPAREN EXPR RPAREN {$$ = $2;}
       | NOT FACTOR {$$ = opr(NOT, 1, $2);}
       | IDENTIFIER {$$ = id($1);}
       | CONST {$$ = $1;}
       | ARR_ACCESS {$$ = $1;}
       ;

ARR_ACCESS : IDENTIFIER LBRACKET EXPR RBRACKET {$$ = opr(ARR, 2, id($1), $3);}

CONST : INT_CONST {$$ = con($1);}
      | REAL_CONST {$$ = con($1);}
      | CHAR_CONST {$$ = con($1);}
      | BOOLEAN_CONST {$$ = con($1);}
      ;

%%

void yyerror()
{   //printTable();
    printf("Syntax Error\n");
    exit(0);
}

int main()
{
    yyin = fopen("input.txt","r");
    yyparse();
    //printTable();
    printf("Parse Successful!\n");
    //print_Arr_Table();
    printf("\n");
    //print_Id_Table();
    return 0;
}

nodeType *con(char *value)
{
	nodeType *p;
	/* allocate node */
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	/* copy information */
	p->type = typeCon;
	strcpy(p->con.value, value);
	return p;
}
nodeType *id(char *identifier) {
	nodeType *p;
	/* allocate node */
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	/* copy information */
	p->type = typeId;
	strcpy(p->id.name,identifier);
//	printf("The copied identifier %s\n", p->id.name);
	return p;
}

nodeType *opr(int oper, int nops, ...)
{
	va_list ap;
	nodeType *p;
	int i;
	/* allocate node, extending op array */
	if ((p = malloc(sizeof(nodeType) +(nops-1) * sizeof(nodeType *))) == NULL)
		yyerror("out of memory");
	/* copy information */
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for (i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
	va_end(ap);
	return p;
}

