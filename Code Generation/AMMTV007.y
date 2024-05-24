%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<math.h>
    #include<string.h>
    #include<ctype.h>
    #include<limits.h>
    extern FILE *yyin;
    
    int label = 0;
    int tempVariable = 0;
    int loopL[100];
    int indent = 0;

    char* genTempVariable(int id){
        char* temp = (char*)malloc(10*sizeof(char));
        temp[0] = 'T';
        snprintf(temp, 10, "T%d", id);
        return temp;
    }

    int gencode(char* lhs, char* op, char* rhs){
        printf("\nT%d := %s %s %s \n", tempVariable, lhs, op, rhs);
        return tempVariable;
    }

    void assignment(char* lhs, char* rhs){
        printf("\n%s := %s \n", lhs, rhs);
    }
    
    void assignment_arr(char* lhs1, char* lhs2, char* rhs){
    	printf("\n%s[%s] := %s \n", lhs1, lhs2, rhs);
    }
    
    void increment_var(char* var){
    	printf("%s = %s + 1\n", var, var);
    }
    
    void decrement_var(char* var){
    	printf("%s = %s - 1\n", var, var);
    }
%}

%union{
    char *lexeme;
}

%left MUL DIV
%left PLUS MINUS 

%token <lexeme> IDENTIFIER BOOLEAN_CONST INT_CONST REAL_CONST CHAR_CONST STRING
%token <lexeme> PROGRAM INT REAL BOOLEAN CHAR VAR TYPE IF THEN ELSE FOR DO WHILE ARRAY TO DOWNTO OF START END READ WRITE
%token <lexeme> PLUS MINUS MUL DIV MOD GTR LESS GTR_EQ LESS_EQ EQ NOT_EQ AND OR NOT ASS
%token <lexeme> SEMICOLON COMMA COLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SQT DQT DOT
%token <lexeme> NEWLINE UNK END_OF_FILE
%type <lexeme> TYPE_SPECIFIER CONST EXPR ARITHMETIC FACTOR TERM COMP_OP ARR_ACCESS
%%

S : PROGRAM IDENTIFIER SEMICOLON BLOCK DOT 
  ;

BLOCK : VAR_DECL START STMT_LIST END 
      ;
VAR_DECL : VAR VAR_DECL_LIST
         | 
         ;

VAR_DECL_LIST : VAR_DECL_LIST VAR_DECL_ITEM SEMICOLON
              |  
              ;

VAR_DECL_ITEM : IDENTIFIER_LIST COLON TYPE_SPECIFIER 
	      | IDENTIFIER_LIST COLON ARRAY LBRACKET INT_CONST DOT DOT INT_CONST RBRACKET OF TYPE_SPECIFIER
	      ;


	      
IDENTIFIER_LIST : IDENTIFIER 
                | IDENTIFIER_LIST COMMA IDENTIFIER 
                ; 

READ_LIST : IDENTIFIER 
	  | IDENTIFIER LBRACKET EXPR RBRACKET 
	  | READ_LIST COMMA IDENTIFIER 
	  | READ_LIST COMMA IDENTIFIER LBRACKET EXPR RBRACKET
	  ;

TYPE_SPECIFIER : INT {$$ = "int";}
               | REAL {$$ = "real";}
               | BOOLEAN {$$ = "boolean";}
               | CHAR {$$ = "char";}
               ;

STMT_LIST : STMT SEMICOLON STMT_LIST
	  |
	  ;
          
SMP_STMT_LIST : SMP_STMT SEMICOLON SMP_STMT_LIST
	      |
	      ;

STMT : {printf("\nL%d: \n", ++label);} WHILE_STMT 
     | {printf("\nL%d: \n", ++label);} FOR_STMT
     | SMP_STMT
     ;

SMP_STMT : ASSIGNMENT_STMT
     	 | READ_STMT
     	 | WRITE_STMT
     	 | {printf("\nL%d:\n", ++label);} IF_STMT
     	 ;
   
ASSIGNMENT_STMT : IDENTIFIER ASS EXPR {assignment($1, $3);}
		| IDENTIFIER LBRACKET EXPR RBRACKET ASS EXPR {assignment_arr($1, $3, $6);}
		; 

READ_STMT : READ LPAREN READ_LIST RPAREN
          ;

WRITE_STMT : WRITE LPAREN DQT STRING DQT RPAREN
	   | WRITE LPAREN DQT STRING DQT COMMA VAR_LIST RPAREN
           | WRITE LPAREN VAR_LIST RPAREN
           ;

VAR_LIST : VAR_LIST COMMA EXPR 
	 | EXPR 
	 ;

IF_STMT :  IF EXPR THEN START {printf("if false %s goto L%d\n",$2  ,++label);} SMP_STMT_LIST END IF_CONT
        ;

IF_CONT : {printf("goto L%d\n", label+1);} ELSE START {printf("L%d: \n",label);} SMP_STMT_LIST END {printf("L%d:\n", ++label);}
	| {printf("L%d: \n",label);}
	;

WHILE_STMT : WHILE EXPR DO START {
        printf("L%d:\n", ++label);
        loopL[indent]=label;
        
        printf("if false %s goto L%d\n", $2, ++label);
        loopL[indent+1]=label; 
     } 
     SMP_STMT_LIST 
     { 
        printf("goto L%d\n", loopL[indent]); 
        printf("L%d:\n", loopL[++indent]); 
    } 
    END 
    ;

FOR_STMT : FOR IDENTIFIER ASS EXPR TO EXPR DO START {
                        printf("for_loop:\n");
                        assignment($2, $4);
                        printf("L%d:\n", ++label); 
                        loopL[indent]=label;
                        printf("if %s <= %s goto L%d\n", $2, $6, ++label); 
                        printf("goto L%d\n", ++label);
                        loopL[indent+1]=label; 
                        printf("L%d:\n", label - 1); 
	   }
	   SMP_STMT_LIST 
	   {
                        increment_var($2); 
                        printf("goto L%d\n", loopL[indent]); 
                        printf("L%d:\n", loopL[++indent]); 
    	   } 
           END 
	 | FOR IDENTIFIER ASS EXPR DOWNTO EXPR DO START {
                        printf("for_loop:\n");
                        assignment($2, $4);
                        printf("L%d:\n", ++label); 
                        loopL[indent]=label;
                        printf("if %s > %s goto L%d\n", $2, $6, ++label); 
                        printf("goto L%d\n", ++label);
                        loopL[indent+1]=label; 
                        printf("L%d:\n", label - 1); 
    }
    SMP_STMT_LIST 
    {
                        decrement_var($2);
                        printf("goto L%d\n", loopL[indent]);
                        printf("L%d:\n", loopL[++indent]);
                    }
    END 
	 ;

EXPR : EXPR COMP_OP ARITHMETIC {int a = gencode($1, $2, $3);
		                char* tempVar = genTempVariable(a);
		                $$ = tempVar;
		                tempVariable++;
		               }
     | ARITHMETIC {$$ = $1;}
     ;

ARITHMETIC : ARITHMETIC PLUS TERM {int a = gencode($1, $2, $3);
		                   char* tempVar = genTempVariable(a);
		                   $$ = tempVar;
		                   tempVariable++;
		                  }
	   | ARITHMETIC MINUS TERM {int a = gencode($1, $2, $3);
                          	    char* tempVar = genTempVariable(a);
                          	    $$ = tempVar;
                          	    tempVariable++;
                         	   }
           | ARITHMETIC OR TERM {int a = gencode($1, $2, $3);
                          	 char* tempVar = genTempVariable(a);
                          	 $$ = tempVar;
                          	 tempVariable++;
                         	}
	   | TERM {$$ = $1;}
	   ;

COMP_OP : GTR {$$ = $1;}
        | LESS {$$ = $1;}
        | GTR_EQ {$$ = $1;}
        | LESS_EQ {$$ = $1;}
        | NOT_EQ {$$ = $1;}
        | EQ {$$ = $1;}
        ;

TERM : TERM MUL FACTOR {int a = gencode($1, $2, $3);
                        char* tempVar = genTempVariable(a);
                        $$ = tempVar;
                        tempVariable++;
                       }
     | TERM DIV FACTOR {int a = gencode($1, $2, $3);
                        char* tempVar = genTempVariable(a);
                        $$ = tempVar;
                        tempVariable++;
                       }
     | TERM MOD FACTOR {int a = gencode($1, $2, $3);
                        char* tempVar = genTempVariable(a);
                        $$ = tempVar;
                        tempVariable++;
                       }
     | TERM AND FACTOR {int a = gencode($1, $2, $3);
                        char* tempVar = genTempVariable(a);
                        $$ = tempVar;
                        tempVariable++;
     		       }
     | FACTOR {$$ = $1;}
     ;

FACTOR : LPAREN EXPR RPAREN {$$ = $2;}
       | NOT FACTOR {int a = gencode("", $1, $2);
		     char* tempVar = genTempVariable(a);
		     $$ = tempVar;
		     tempVariable++;
		    }
       | IDENTIFIER {$$ = $1;}
       | CONST {$$ = $1;}
       | ARR_ACCESS {$$ = $1;}
       ;

ARR_ACCESS : IDENTIFIER LBRACKET EXPR RBRACKET {$$ = strcat($1,strcat($2,strcat($3,$4)));}

CONST : INT_CONST {$$ = $1;}
      | REAL_CONST {$$ = $1;}
      | CHAR_CONST {$$ = $1;}
      | BOOLEAN_CONST {$$ = $1;}
      ;

%%

void yyerror()
{   
    printf("Syntax Error\n");
    exit(0);
}

int main()
{
    yyin = fopen("input.txt","r");
    yyparse();
    printf("Parse Successful!\n");
    printf("\n");
    return 0;
}
