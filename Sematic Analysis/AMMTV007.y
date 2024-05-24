%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<math.h>
    #include<string.h>
    #include<ctype.h>
    #include<limits.h>
    #include "table.c"
    extern FILE *yyin;
    
    int decCounter = 0;
    int scopeCounter = 0;
    int list_c = 0;
    char *listType[100];
%}

%union{
    struct{
        char *lexeme;
        float val;
    }t;
}

%left PLUS MINUS OR
%left MUL DIV AND MOD
%token <t> IDENTIFIER BOOLEAN_CONST INT_CONST REAL_CONST CHAR_CONST STRING
%token PROGRAM INT REAL BOOLEAN CHAR VAR TYPE IF THEN ELSE FOR DO WHILE ARRAY TO DOWNTO OF START END READ WRITE
%token <t> PLUS MINUS MUL DIV MOD GTR LESS GTR_EQ LESS_EQ EQ NOT_EQ AND OR NOT ASS
%token <t> SEMICOLON COMMA COLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SQT DQT DOT
%token NEWLINE UNK END_OF_FILE
%type <t> TYPE_SPECIFIER CONST EXPR FACTOR TERM COMP_OP ARR_ACCESS ARITHMETIC
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

VAR_DECL_ITEM : IDENTIFIER_LIST COLON TYPE_SPECIFIER {insertEntry($3.lexeme);}
	      | IDENTIFIER_LIST COLON ARRAY LBRACKET INT_CONST DOT DOT INT_CONST RBRACKET OF TYPE_SPECIFIER {insertEntryArr($11.lexeme,(int)$5.val,(int)$8.val); printf("value of integer is %d and %d resp\n",(int)$5.val,(int)$8.val);}
	      ;


	      
IDENTIFIER_LIST : IDENTIFIER {dec[decCounter] = *(struct dec*)malloc(sizeof(dec));
			      dec[decCounter].name = $1.lexeme; 
			      dec[decCounter].val = INT_MIN; 
			      decCounter++;
			     }
                | IDENTIFIER_LIST COMMA IDENTIFIER {dec[decCounter] = *(struct dec*)malloc(sizeof(dec)); 
						    dec[decCounter].name = $3.lexeme; 
						    dec[decCounter].val = INT_MIN; 
						    decCounter++;
						   }
                ; 

READ_LIST : IDENTIFIER {if(!isPresentId($1.lexeme)){
        		      	printf("ERROR: Identifier %s not declared\n", $1.lexeme);
                              	exit(0);
                       }
                       }
	  | IDENTIFIER LBRACKET EXPR RBRACKET {if(!isPresentArr($1.lexeme)){
        		      			printf("ERROR: Array %s not declared\n", $1.lexeme);
                              			exit(0);
                       				}
                       				else{
                       					if(!findArrSize($1.lexeme, $3.val)){
								printf("ERROR: Array %s out of bounds\n", $1.lexeme); 
								exit(0);
							} 
                       				}
                       			       }
	  | READ_LIST COMMA IDENTIFIER {if(!isPresentId($3.lexeme)){
					      	printf("ERROR: Identifier %s not declared\n", $3.lexeme);
				              	exit(0);
				       }
				       }
	  | READ_LIST COMMA IDENTIFIER LBRACKET EXPR RBRACKET {if(!isPresentArr($3.lexeme)){
					      			printf("ERROR: Array %s not declared\n", $3.lexeme);
				              			exit(0);
				       				}
				       				else{
				       					if(!findArrSize($3.lexeme, $5.val)){
										printf("ERROR: Array %s out of bounds\n", $3.lexeme); 
										exit(0);
									} 
                       						}
                       			       		       }
	  ;

TYPE_SPECIFIER : INT {$$.lexeme = "int";}
               | REAL {$$.lexeme = "real";}
               | BOOLEAN {$$.lexeme = "boolean";}
               | CHAR {$$.lexeme = "char";}
               ;

STMT_LIST : STMT SEMICOLON STMT_LIST
	  |
	  ;
          
SMP_STMT_LIST : SMP_STMT SEMICOLON SMP_STMT_LIST
	      |
	      ;

STMT : WHILE_STMT 
     | FOR_STMT
     | SMP_STMT
     ;

SMP_STMT : ASSIGNMENT_STMT
     	 | READ_STMT
     	 | WRITE_STMT
     	 | IF_STMT
     	 ;
   
ASSIGNMENT_STMT : IDENTIFIER ASS EXPR {typeCheck($1.lexeme,$3.lexeme); 
				       updateID($1.lexeme,$3.val);
				      }
		| IDENTIFIER LBRACKET EXPR RBRACKET ASS EXPR {if(!findArrSize($1.lexeme, $3.val)){
							 	printf("ERROR: Array %s out of bounds\n", $1.lexeme); 
								exit(0);
							     }
							      typeCheckArr($1.lexeme, $6.lexeme);
							      updateArr($1.lexeme, $3.val, $6.val);
							     }
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

IF_STMT :  IF EXPR THEN START SMP_STMT_LIST END ELSE START SMP_STMT_LIST END {if(strcmp($2.lexeme,"boolean")!=0){print_Id_Table(); 
											printf("ERROR: Boolean type expected\n");
											exit(0);
									     		}
								      	     }
        |  IF EXPR THEN START SMP_STMT_LIST END {if(strcmp($2.lexeme,"boolean")!=0){
        						 print_Id_Table(); 
							 printf("ERROR: Boolean type expected\n");
							 exit(0);
							 }
				      		}
        ;


WHILE_STMT : WHILE EXPR DO START SMP_STMT_LIST END {if(strcmp($2.lexeme,"boolean")!=0){
        						 print_Id_Table(); 
							 printf("ERROR: Boolean type expected\n");
							 exit(0);
							 }
				      		   }
           ;

FOR_STMT : FOR IDENTIFIER ASS EXPR TO EXPR DO START SMP_STMT_LIST END {if(strcmp($4.lexeme, "int")!=0 || strcmp($6.lexeme, "int")!=0){
								       		print_Id_Table(); 
										printf("ERROR: Expected an integer expression.\n");
										exit(0);
								       }
								       typeCheck($2.lexeme,$4.lexeme); 
								       updateID($2.lexeme,$4.val);
								       typeCheck($2.lexeme,$6.lexeme);
								      }
	 | FOR IDENTIFIER ASS EXPR DOWNTO EXPR DO START SMP_STMT_LIST END {if(strcmp($4.lexeme, "int")!=0 || strcmp($6.lexeme, "int")!=0){
								       		print_Id_Table(); 
										printf("ERROR: Expected an integer expression.\n");
										exit(0);
								       	   }
	 								   typeCheck($2.lexeme,$4.lexeme); 
								       	   updateID($2.lexeme,$4.val);
								       	   typeCheck($2.lexeme,$6.lexeme);
								      	  }
	 ;

EXPR : EXPR COMP_OP TERM {if(strcmp($1.lexeme,"char")==0 || strcmp($3.lexeme,"char")==0){
				print_Id_Table(); 
				printf("ERROR: Type mismatch for expression\n");
				exit(0);
				}
                         $$.lexeme = "boolean";
                         $$.val = (float)comparator($1.val,$3.val,$2.lexeme);
                         }
     | ARITHMETIC {$$.lexeme = $1.lexeme;
     	     $$.val = $1.val;
     	    }
     ;

COMP_OP : GTR {$$.lexeme = $1.lexeme;}
        | LESS {$$.lexeme = $1.lexeme;}
        | GTR_EQ {$$.lexeme = $1.lexeme;}
        | LESS_EQ {$$.lexeme = $1.lexeme;}
        | NOT_EQ {$$.lexeme = $1.lexeme;}
        | EQ {$$.lexeme = $1.lexeme;}
        ;

ARITHMETIC : ARITHMETIC PLUS TERM {if(strcmp($1.lexeme,"char")==0 || strcmp($3.lexeme,"char")==0 || strcmp($1.lexeme,"boolean")==0 || strcmp($3.lexeme,"boolean")==0){
				print_Id_Table(); 
				printf("ERROR: Type mismatch for expression\n");
				exit(0);
				} 
			if(strcmp($1.lexeme,"real")==0 || strcmp($3.lexeme,"real")==0){
				$$.lexeme = "real";
				$$.val = $1.val + $3.val;
			}
			else {
				$$.lexeme = "int";
				$$.val = $1.val + $3.val;	
			}
			}
	   | ARITHMETIC MINUS TERM {if(strcmp($1.lexeme,"char")==0 || strcmp($3.lexeme,"char")==0 || strcmp($1.lexeme,"boolean")==0 || strcmp($3.lexeme,"boolean")==0){
				print_Id_Table(); 
				printf("ERROR: Type mismatch for expression\n");
				exit(0);
				} 
			if(strcmp($1.lexeme,"real")==0 || strcmp($3.lexeme,"real")==0){
				$$.lexeme = "real";
				$$.val = $1.val - $3.val;
			}
			else {
				$$.lexeme = "int";
				$$.val = $1.val - $3.val;
			}
     			}
           | ARITHMETIC OR TERM {if(strcmp($1.lexeme,"boolean")!=0 || strcmp($3.lexeme,"boolean")!=0){
			 		print_Id_Table(); 
					printf("ERROR: Type mismatch for expression\n");
					exit(0);
			 	}
			 	$$.lexeme = "boolean";
                         	$$.val = (float)comparator($1.val,$3.val,$2.lexeme);
			 	}
	   | TERM {$$ = $1;}
	   ;

TERM : TERM MUL FACTOR {if(strcmp($1.lexeme,"char")==0 || strcmp($3.lexeme,"char")==0 || strcmp($1.lexeme,"boolean")==0 || strcmp($3.lexeme,"boolean")==0){
				print_Id_Table(); 
				printf("ERROR: Type mismatch for expression\n");
				exit(0);
				} 
			if(strcmp($1.lexeme,"real")==0 || strcmp($3.lexeme,"real")==0){
				$$.lexeme = "real";
				$$.val = $1.val * $3.val;
			}
			else {
				$$.lexeme = "int";
				$$.val = $1.val * $3.val;	
			}
     			}
     | TERM DIV FACTOR {if(strcmp($1.lexeme,"char")==0 || strcmp($3.lexeme,"char")==0 || strcmp($1.lexeme,"boolean")==0 || strcmp($3.lexeme,"boolean")==0){
				print_Id_Table(); 
				printf("ERROR: Type mismatch for expression\n");
				exit(0);
				} 
			if(strcmp($1.lexeme,"real")==0 || strcmp($3.lexeme,"real")==0){
				$$.lexeme = "real";
				$$.val = $1.val / $3.val;
			}
			else {
				if($3.val == 0){
					print_Id_Table(); 
					printf("ERROR: Division by zero\n");
					exit(0);
				}
				$$.lexeme = "int";
				$$.val = (int)$1.val / (int)$3.val;	
			}
     			}
     | TERM MOD FACTOR {if(strcmp($1.lexeme,"int")!=0 || strcmp($3.lexeme,"int")!=0){
     				print_Id_Table(); 
     				printf("ERROR: Type mismatch for operator\n");
     				exit(0);
     			}
     			if($3.val == 0){
				print_Id_Table(); 
				printf("ERROR: Modulo by zero\n");
				exit(0);
			}
     			$$.lexeme = $1.lexeme; 
     			$$.val = (int)$1.val % (int)$3.val;
     			}
     | TERM AND FACTOR {if(strcmp($1.lexeme,"boolean")!=0 || strcmp($3.lexeme,"boolean")!=0){
			 		print_Id_Table(); 
					printf("ERROR: Type mismatch for expression\n");
					exit(0);
			 	}
			 $$.lexeme = "boolean";
                         $$.val = (float)comparator($1.val,$3.val,$2.lexeme);
			 }
     | FACTOR {$$.lexeme = $1.lexeme; $$.val = $1.val;}
     ;

FACTOR : LPAREN EXPR RPAREN {$$.lexeme = $2.lexeme; $$.val = $2.val;}
       | IDENTIFIER {bool found = true;
		     for(int i = 0; i<id_count; i++){
		        if(strcmp(id_table[i].name,$1.lexeme)==0){
		            found = false;
		            $$.lexeme = id_table[i].type;
		            if(id_table[i].val == INT_MIN){
		            	printf("ERROR: Uninitialized variable %s\n", $1.lexeme);
		            	exit(0);
		            }
		            $$.val = id_table[i].val;
		            break;
		        }
		     }
		     if(found){
		        printf("ERROR: Undeclared variable %s\n", $1.lexeme);
		        exit(0);
		    }
		    }
       | NOT FACTOR {if(strcmp($2.lexeme,"boolean")!=0){
     				print_Id_Table(); 
     				printf("ERROR: Type mismatch for operator\n");
     				exit(0);
     			}
     		   $$.lexeme = $2.lexeme; 
     		   if($2.val == 0){
     		   	$2.val = 1;
     		   }
     		   else{
     		   	$2.val = 0;
     		   }
     		  }
       | CONST {$$.lexeme = $1.lexeme; $$.val = $1.val;}
       | ARR_ACCESS {$$.lexeme = $1.lexeme; $$.val = $1.val;}
       ;

ARR_ACCESS : IDENTIFIER LBRACKET EXPR RBRACKET {if(!findArrSize($1.lexeme, $3.val)){
							printf("ERROR: Array %s out of bounds\n", $1.lexeme); 
							exit(0);
						} 
						$$.lexeme = findArrType($1.lexeme); 
						$$.val = findArrVal($1.lexeme, $3.val);
						}

CONST : INT_CONST {$$.val = $1.val; $$.lexeme = "int"; }
      | REAL_CONST {$$.val = $1.val; $$.lexeme = "real";}
      | CHAR_CONST {$$.val = $1.val; $$.lexeme = "char";}
      | BOOLEAN_CONST {$$.val = $1.val; $$.lexeme = "boolean";}
      ;

%%

void insertEntry(char *t){
    for(int i = 0; i<decCounter; i++){
        insertID(dec[i].name, t);
        if(dec[i].val != INT_MIN){
            if(strcmp(dec[i].type, t)!=0){
                printf("ERROR: Type mismatch for variable %s\n", dec[i].name);
                exit(0);
            }
            updateID(dec[i].name,dec[i].val);
        }
    }
    decCounter = 0;                   
}

void insertEntryArr(char *t, int c1, int c2){
	printf("In insertEntryArr values : %d and %d\n", c1, c2);
	for(int i = 0; i<decCounter; i++){
		insertArr(dec[i].name, t, c1, c2);
		if(dec[i].val != INT_MIN){
		    if(strcmp(dec[i].type, t)!=0){
		        printf("ERROR: Type mismatch for variable %s\n", dec[i].name);
		        exit(0);
		    }
		    updateID(dec[i].name,dec[i].val);
        	}
    	}
    	decCounter = 0;
}

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
