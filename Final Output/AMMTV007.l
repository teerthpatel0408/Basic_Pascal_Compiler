%{
    #include "header.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #include "y.tab.h"
    int line = 1;
%}

alp [a-zA-Z]
digit [0-9]
us [_]
newline [\n]
space [ ]
tab [\t]

%x strings
%%

{newline} {line++;}
{space} {;}
{tab} {;}
"//".* {;}

[pP][rR][oO][gG][rR][aA][mM] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return PROGRAM;}
[vV][aA][rR] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return VAR;}
[iI][nN][tT][eE][gG][eE][rR] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return INT;}
[cC][hH][aA][rR] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return CHAR;}
[rR][eE][aA][lL] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return REAL;}
[iI][fF] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return IF;}
[tT][hH][eE][nN] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return THEN;}
[eE][lL][sS][eE] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return ELSE;}
[fF][oO][rR] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return FOR;}
[wW][hH][iI][lL][eE] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return WHILE;}
[dD][oO] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return DO;}
[bB][oO][oO][lL][eE][aA][nN] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return BOOLEAN;}
[aA][rR][rR][aA][yY] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return ARRAY;}
[aA][nN][dD] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return AND;}
[oO][rR] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return OR;}
[nN][oO][tT] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return NOT;}
[bB][eE][gG][iI][nN] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return START;}
[eE][nN][dD] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return END;}
[rR][eE][aA][dD] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return READ;}
[wW][rR][iI][tT][eE] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return WRITE;}
[tT][oO] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return TO;}
[oO][fF] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return OF;}
[dD][oO][wW][nN][tT][oO] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "KEYWORD"); return DOWNTO;}

[tT][rR][uU][eE] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "BOOLEAN_CONST"); return BOOLEAN_CONST;}
[fF][aA][lL][sS][eE] {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "BOOLEAN_CONST"); return BOOLEAN_CONST;}

{alp}({alp}|{digit}|{us})* {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "IDENTIFIER"); return IDENTIFIER;}
"-"?{digit}+ {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "INT_CONST"); return INT_CONST;}
"-"?{digit}+\.{digit}+ {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "REAL_CONST"); return REAL_CONST;}
\'.\' {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "CHAR_CONST"); return CHAR_CONST;}
\\n {return NEWLINE;}
"+" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return PLUS;}
"-" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return MINUS;}
"*" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return MUL;}
"/" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return DIV;}
"\%" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return MOD;}
">" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return GTR;}
"<" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return LESS;}
">=" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return GTR_EQ;}
"<=" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return LESS_EQ;}
"=" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return EQ;}
"<>" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return NOT_EQ;}
":=" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "OPERATOR"); return ASS;}

";" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return SEMICOLON;}
":" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return COLON;}
"," {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return COMMA;}
"\(" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return LPAREN;}
"\)" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return RPAREN;}
"\{" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return LBRACE;}
"\}" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return RBRACE;}
"\[" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return LBRACKET;}
"\]" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return RBRACKET;}
\' {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); return SQT;}
\" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); BEGIN(strings); return DQT;}
\. {insertIntoTable(line, yytext, "SYMBOL"); return DOT;}
. {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
"/*" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
"*/" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
({digit})+({alp}|{digit}|{us})* {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
({us})+({alp}|{digit}|{us})* {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}

<strings>\" {strcpy(yylval.string, yytext); insertIntoTable(line, yytext, "SYMBOL"); BEGIN(INITIAL); return DQT;}
<strings>.*/\" {strcpy(yylval.string, yytext); return STRING;}

%%
typedef struct node {
    char *lexeme;
    char *token;
    struct node *next;
} node;

node *sym_table[1000];

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
    printf("\nSYMBOL TABLE----------------------\n");
    printf("\nLine\tLexeme\tToken\n\n");
    for(int i=0; i<1000; i++){
        if(sym_table[i] != NULL){
            node *ptr = sym_table[i];
            while(ptr != NULL){
                printf("%d\t%s\t%s\n", i, ptr->lexeme, ptr->token);
                ptr = ptr->next;
            }
        }
    }
    printf("\n");
}

int yywrap()
{
	return 1;
}
