%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    int line = 1;
    enum tokens {KEYWORD=1, IDENTIFIER, BOOLEAN_CONST, INT_CONST, REAL_CONST, CHAR_CONST, OPERATOR, SYMBOL, ARR};
    enum keywords {PROGRAM=100, INT, REAL, BOOLEAN, CHAR, VAR, TYPE, IF, THEN, ELSE, FOR, DO, WHILE, ARRAY, TO, DOWNTO, OF, START, END, READ, WRITE, AND, OR, NOT};
    enum operators {PLUS=200, MINUS, MUL, DIV, MOD, GTR, LESS, GTR_EQ, LESS_EQ, EQ, NOT_EQ, ASS};
    enum symbols {SEMICOLON=300, COMMA, COLON, LPAREN, RPAREN, LBRACE, RBRACE, LBRACKET, RBRACKET, SQT, DQT, DOT, NEWLINE};
    enum unknown {UNK=400};
%}

alp [a-zA-Z]
digit [0-9]
us [_]
newline [\n]
space [ ]
tab [\t]

%x string

%%

{newline} {line++;}
{space} {;}
{tab} {;}
"//".* {;}

[pP][rR][oO][gG][rR][aA][mM] {return PROGRAM;}
[vV][aA][rR] {return VAR;}
[iI][nN][tT][eE][gG][eE][rR] {return INT;}
[cC][hH][aA][rR] {return CHAR;}
[rR][eE][aA][lL] {return REAL;}
[iI][fF] {return IF;}
[tT][hH][eE][nN] {return THEN;}
[eE][lL][sS][eE] {return ELSE;}
[fF][oO][rR] {return FOR;}
[wW][hH][iI][lL][eE] {return WHILE;}
[dD][oO] {return DO;}
[bB][oO][oO][lL][eE][aA][nN] {return BOOLEAN;}
[aA][rR][rR][aA][yY] {return ARRAY;}
[aA][nN][dD] {return AND;}
[oO][rR] {return OR;}
[nN][oO][tT] {return NOT;}
[bB][eE][gG][iI][nN] {return START;}
[eE][nN][dD] {return END;}
[rR][eE][aA][dD] {return READ;}
[wW][rR][iI][tT][eE] {return WRITE;}
[tT][oO] {return TO;}
[oO][fF] {return OF;}
[dD][oO][wW][nN][tT][oO] {return DOWNTO;}

[tT][rR][uU][eE] {return BOOLEAN_CONST;}
[fF][aA][lL][sS][eE] {return BOOLEAN_CONST;}

{alp}({alp}|{digit}|{us})* {return IDENTIFIER;}
"-"?{digit}+ {return INT_CONST;}
"-"?{digit}+\.{digit}+ {return REAL_CONST;}
\'.\' {return CHAR_CONST;}
\\n {return NEWLINE;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"\%" {return MOD;}
">" {return GTR;}
"<" {return LESS;}
">=" {return GTR_EQ;}
"<=" {return LESS_EQ;}
"=" {return EQ;}
"<>" {return NOT_EQ;}
":=" {return ASS;}
";" {return SEMICOLON;}
":" {return COLON;}
"," {return COMMA;}
"\(" {return LPAREN;}
"\)" {return RPAREN;}
"\{" {return LBRACE;}
"\}" {return RBRACE;}
"\[" {return LBRACKET;}
"\]" {return RBRACKET;}
\' {return SQT;}
\" {BEGIN(string); return DQT;}
\. {return DOT;}
. {return UNK;}
"/*" {return UNK;}
"*/" {return UNK;}
({digit})+({alp}|{digit}|{us})* return UNK;
({us})+({alp}|{digit}|{us})* return UNK;

<string>\" {BEGIN(INITIAL); return DQT;}
<string>.*/\" {;} 

%%
typedef struct node {
    char *lexeme;
    char *token;
    struct node *next;
} node;

node *sym_table[2000];

node *createNode(char *lexeme, char *token){
    node *temp = (node*)malloc(sizeof(node));
    temp->lexeme = (char*)malloc(sizeof(char)*strlen(lexeme));
    temp->token = (char*)malloc(sizeof(char)*strlen(token));
    strcpy(temp->lexeme, lexeme);
    strcpy(temp->token, token);
    temp->next = NULL;
    return temp;
}

void insertIntoTable(int line, char *yytext, char *token){
    node *temp = createNode(yytext, token);
    if(sym_table[line] == NULL){
        sym_table[line] = temp;
        return;
    }

    node *ptr = sym_table[line];
    while(ptr->next != NULL){
        ptr = ptr->next;
    }
    ptr->next = temp;
}

void printTable(){
    printf("\nLine\tLexeme\tToken\n\n");
    for(int i=0; i<2000; i++){
        if(sym_table[i] != NULL){
            node *ptr = sym_table[i];
            while(ptr != NULL){
                printf("%d\t%s\t%s\n", i, ptr->lexeme, ptr->token);
                ptr = ptr->next;
            }
        }
    }
}

int main(){
    yyin = fopen("input.txt", "r");
    int scan = yylex();
    while(scan){
        switch(scan){
            case IDENTIFIER: insertIntoTable(line, yytext, "IDENTIFIER"); break;
            case INT_CONST: insertIntoTable(line, yytext, "INT_CONST"); break;
            case REAL_CONST: insertIntoTable(line, yytext, "REAL_CONST"); break;
            case CHAR_CONST: insertIntoTable(line, yytext, "CHAR_CONST"); break;
            case BOOLEAN_CONST: insertIntoTable(line, yytext, "BOOLEAN_CONST"); break;
            case ARR: insertIntoTable(line, yytext, "ARR"); break;
            case 100 ... 199: insertIntoTable(line,yytext,"KEYWORDS"); break;
            case 200 ... 299: insertIntoTable(line,yytext,"OPERATORS"); break;
            case 300 ... 399: insertIntoTable(line,yytext,"SYMBOLS"); break;
            case UNK: insertIntoTable(line,yytext,"UNKNOWN"); break;
            default: break;
        }
        scan = yylex();
    }
    printTable();
}

int yywrap()
{
	return 1;
}
